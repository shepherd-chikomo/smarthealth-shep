import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/feature_flags/feature_flags_notifier.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/clinical_repository.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/features/clinical/pdf_service.dart';
import 'package:my_practice/features/clinical/voice_dictation_service.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';

class EncounterScreen extends ConsumerStatefulWidget {
  const EncounterScreen({
    super.key,
    required this.patientId,
    this.consultationId,
    this.queueEntryId,
  });

  final String patientId;
  final String? consultationId;
  final String? queueEntryId;

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  final _sections = <String, TextEditingController>{};
  String? _consultationId;
  String? _selectedIcd11;
  String? _selectedIcd11Description;
  List<EdlizRecommendation> _edliz = [];
  String? _activeVoiceSection = 'historyOfPresentIllness';
  Patient? _patient;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    for (final key in _sectionKeys) {
      _sections[key] = TextEditingController();
    }
    _consultationId = widget.consultationId;
    _loadPatient();
    _loadOrCreate();
  }

  Future<void> _loadPatient() async {
    var p = await ref.read(patientRepositoryProvider).findById(widget.patientId);
    if (p == null && !MyPracticeConfig.skipAuthForTesting) {
      try {
        await ref.read(patientRepositoryProvider).getChart(widget.patientId);
        p = await ref.read(patientRepositoryProvider).findById(widget.patientId);
      } catch (_) {}
    }
    if (mounted) setState(() => _patient = p);
  }

  static const _sectionKeys = [    'chiefComplaint',
    'historyOfPresentIllness',
    'pastMedicalHistory',
    'surgicalHistory',
    'familyHistory',
    'socialHistory',
    'examinationNotes',
    'assessment',
    'plan',
    'followUpPlan',
  ];

  Future<void> _loadOrCreate() async {
    final db = ref.read(appDatabaseProvider);
    final clinical = ref.read(clinicalRepositoryProvider);

    if (_consultationId != null) {
      final existing = await (db.select(db.consultations)
            ..where((t) => t.id.equals(_consultationId!)))
          .getSingleOrNull();
      if (existing != null) {
        _hydrateFromRow(existing);
        return;
      }
    }

    try {
      final id = await clinical.ensureConsultation(
        consultationId: _consultationId,
        patientId: widget.patientId,
        walkInSessionId: widget.queueEntryId,
      );

      if (widget.queueEntryId != null) {
        await ref.read(queueRepositoryProvider).updateStatus(
              widget.queueEntryId!,
              'in_progress',
            );
      }

      final row = await (db.select(db.consultations)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      _hydrateFromRow(row);
      if (mounted) setState(() => _consultationId = id);
    } on ProviderProfileRequired catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      context.pop();
    }
  }

  void _hydrateFromRow(Consultation existing) {
    _sections['chiefComplaint']!.text = existing.chiefComplaint ?? '';
    _sections['historyOfPresentIllness']!.text =
        existing.historyOfPresentIllness ?? '';
    _sections['pastMedicalHistory']!.text = existing.pastMedicalHistory ?? '';
    _sections['surgicalHistory']!.text = existing.surgicalHistory ?? '';
    _sections['familyHistory']!.text = existing.familyHistory ?? '';
    _sections['socialHistory']!.text = existing.socialHistory ?? '';
    _sections['examinationNotes']!.text = existing.examinationNotes ?? '';
    _sections['assessment']!.text = existing.assessment ?? '';
    _sections['plan']!.text = existing.plan ?? '';
    _sections['followUpPlan']!.text = existing.followUpPlan ?? '';
    setState(() => _consultationId = existing.id);
  }

  Future<void> _save({bool complete = false}) async {
    final id = _consultationId!;
    final clinical = ref.read(clinicalRepositoryProvider);

    await clinical.saveConsultation(
      consultationId: id,
      sections: _sections.map((k, v) => MapEntry(k, v.text)),
      complete: complete,
      icd11Code: _selectedIcd11,
      icd11Description: _selectedIcd11Description,
    );

    if (complete && widget.queueEntryId != null) {
      await ref.read(queueRepositoryProvider).updateStatus(
            widget.queueEntryId!,
            'completed',
          );
    }

    if (complete && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Encounter completed${clinical.api != null ? ' and synced' : ''}',
          ),
        ),
      );
      context.go('/patients/${widget.patientId}/chart');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved')),
      );
    }
  }

  Future<void> _searchIcd11(String q) async {
    if (!ref.featureEnabled(FeatureFlagKeys.icd11)) return;
    final db = ref.read(appDatabaseProvider);
    final api = ref.read(clinicalRepositoryProvider).api;

    List<Icd11Code> results;
    if (api != null && q.trim().length >= 2) {
      try {
        final remote = await api.searchIcd11(q);
        results = remote
            .map(
              (m) => Icd11Code(
                code: m['code'] as String? ?? '',
                description: m['description'] as String? ?? '',
                isFavorite: false,
                useCount: 0,
              ),
            )
            .toList();
        for (final c in results) {
          await db.into(db.icd11Codes).insertOnConflictUpdate(
                Icd11CodesCompanion.insert(
                  code: c.code,
                  description: c.description,
                ),
              );
        }
      } catch (_) {
        results = await _localIcd11Search(db, q);
      }
    } else {
      results = await _localIcd11Search(db, q);
    }

    if (!mounted || results.isEmpty) return;
    final picked = await showModalBottomSheet<Icd11Code>(
      context: context,
      builder: (_) => ListView(
        children: results
            .map(
              (c) => ListTile(
                title: Text(c.code),
                subtitle: Text(c.description),
                onTap: () => Navigator.pop(context, c),
              ),
            )
            .toList(),
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedIcd11 = picked.code;
      _selectedIcd11Description = picked.description;
    });
    _sections['assessment']!.text =
        '${_sections['assessment']!.text}\n${picked.code}: ${picked.description}'
            .trim();

    if (ref.featureEnabled(FeatureFlagKeys.edliz)) {
      await _loadEdliz(picked.code);
    }
  }

  Future<List<Icd11Code>> _localIcd11Search(AppDatabase db, String q) {
    return (db.select(db.icd11Codes)
          ..where(
            (t) => t.code.like('%$q%') | t.description.like('%$q%'),
          )
          ..limit(10))
        .get();
  }

  Future<void> _loadEdliz(String icd11Code) async {
    final db = ref.read(appDatabaseProvider);
    final api = ref.read(clinicalRepositoryProvider).api;

    if (api != null) {
      try {
        final remote = await api.getEdlizRecommendations(icd11Code);
        final items = remote
            .map(
              (m) => EdlizRecommendation(
                id: m['id'] as String? ?? icd11Code,
                icd11Code: icd11Code,
                firstLine: m['firstLine'] as String? ?? '',
                alternative: m['alternative'] as String?,
                dosage: m['dosage'] as String?,
                formulation: m['formulation'] as String?,
              ),
            )
            .toList();
        setState(() => _edliz = items);
        return;
      } catch (_) {}
    }

    final edliz = await (db.select(db.edlizRecommendations)
          ..where((t) => t.icd11Code.equals(icd11Code)))
        .get();
    setState(() => _edliz = edliz);
  }

  Future<void> _toggleVoice(String sectionKey) async {
    if (!ref.featureEnabled(FeatureFlagKeys.voiceDictation)) return;
    final voice = VoiceDictationService();
    if (_listening) {
      await voice.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await voice.listen((text) {
      final ctrl = _sections[sectionKey]!;
      ctrl.text = '${ctrl.text} $text'.trim();
    });
  }

  Future<void> _generatePdf() async {
    await PdfService.generateConsultationSummary(
      patientId: widget.patientId,
      sections: _sections.map((k, v) => MapEntry(k, v.text)),
    );
  }

  @override
  void dispose() {
    for (final c in _sections.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientName = _patient != null
        ? PatientFormatters.fullName(_patient!)
        : 'Patient ${widget.patientId.split('-').last}';
    final subtitle = _patient != null
        ? '${_patient!.smarthealthPatientId ?? widget.patientId} · ${PatientFormatters.ageSex(_patient!)}'
        : widget.patientId;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patientName, style: const TextStyle(fontSize: 16)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: isWide
            ? [
                if (ref.featureEnabled(FeatureFlagKeys.voiceDictation))
                  OutlinedButton.icon(
                    onPressed: () => _toggleVoice(_activeVoiceSection!),
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none, size: 18),
                    label: Text(_listening ? 'Listening…' : 'Voice'),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: _generatePdf,
                  tooltip: 'PDF summary',
                ),
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: () => _save(),
                  tooltip: 'Save draft',
                ),
                FilledButton.icon(
                  onPressed:
                      _consultationId == null ? null : () => _save(complete: true),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Complete'),
                ),
                const SizedBox(width: 8),
              ]
            : [
                PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'save':
                        _save();
                      case 'pdf':
                        _generatePdf();
                      case 'voice':
                        _toggleVoice(_activeVoiceSection!);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'save', child: Text('Save draft')),
                    const PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
                    if (ref.featureEnabled(FeatureFlagKeys.voiceDictation))
                      PopupMenuItem(
                        value: 'voice',
                        child: Text(_listening ? 'Stop voice' : 'Voice dictation'),
                      ),
                  ],
                ),
              ],
      ),
      bottomNavigationBar: isWide
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _consultationId == null ? null : () => _save(),
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed:
                            _consultationId == null ? null : () => _save(complete: true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Complete & Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPatientSummary(context, patientName),
                  const SizedBox(height: 16),
                  _buildWorkspace(context),
                  const SizedBox(height: 16),
                  _buildAssistPanel(context),
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 260, child: _buildPatientSummary(context, patientName)),
              Expanded(child: _buildWorkspace(context)),
              SizedBox(width: 280, child: _buildAssistPanel(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPatientSummary(BuildContext context, String patientName) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Summary', style: PracticeDesignTokens.sectionTitle(context)),
          const SizedBox(height: 12),
          if (_patient != null)
            PracticeAvatar(initials: PatientFormatters.initials(_patient!), size: 48),
          const SizedBox(height: 8),
          Text(patientName, style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
          if (_patient != null)
            Text(
              '${PatientFormatters.ageSex(_patient!)} · ${PatientFormatters.insurerLabel(_patient!.insuranceInfo)}',
              style: PracticeDesignTokens.metadata(context),
            ),
          if (widget.queueEntryId != null) ...[
            const Divider(height: 24),
            PracticeStatusChip(
              label: 'From queue',
              tone: PracticeStatusTone.info,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: _sectionKeys.map((key) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _labelFor(key),
                        style: PracticeDesignTokens.sectionTitle(context),
                      ),
                    ),
                    if (ref.featureEnabled(FeatureFlagKeys.voiceDictation))
                      IconButton(
                        icon: Icon(
                          _listening && _activeVoiceSection == key
                              ? Icons.mic
                              : Icons.mic_none,
                          size: 18,
                        ),
                        onPressed: () {
                          _activeVoiceSection = key;
                          _toggleVoice(key);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _sections[key],
                  maxLines: key.contains('History') || key.contains('Notes') ? 4 : 2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onTap: () => _activeVoiceSection = key,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssistPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (ref.featureEnabled(FeatureFlagKeys.icd11))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ICD-11', style: PracticeDesignTokens.sectionTitle(context)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search diagnosis…',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onSubmitted: _searchIcd11,
                  ),
                  if (_selectedIcd11 != null) ...[
                    const SizedBox(height: 8),
                    PracticeStatusChip(
                      label: '$_selectedIcd11 — $_selectedIcd11Description',
                      tone: PracticeStatusTone.info,
                    ),
                  ],
                ],
              ),
            ),
          if (_edliz.isNotEmpty && ref.featureEnabled(FeatureFlagKeys.edliz)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EDLIZ', style: PracticeDesignTokens.sectionTitle(context)),
                  ..._edliz.map(
                    (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.medication_outlined),
                      title: Text(e.firstLine),
                      subtitle: Text(
                        [e.alternative, e.dosage, e.formulation]
                            .whereType<String>()
                            .join(' · '),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _labelFor(String key) {
    return switch (key) {
      'chiefComplaint' => 'Presenting Complaint',
      'historyOfPresentIllness' => 'History of Presenting Illness',
      'pastMedicalHistory' => 'Past Medical History',
      'surgicalHistory' => 'Surgical History',
      'familyHistory' => 'Family History',
      'socialHistory' => 'Social History',
      'examinationNotes' => 'Examination Findings',
      'assessment' => 'Assessment',
      'plan' => 'Treatment Plan',
      'followUpPlan' => 'Follow-Up Plan',
      _ => key,
    };
  }
}
