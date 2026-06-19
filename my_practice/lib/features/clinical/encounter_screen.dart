import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/feature_flags/feature_flags_notifier.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/clinical_repository.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/features/clinical/pdf_service.dart';
import 'package:my_practice/features/clinical/voice_dictation_service.dart';

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
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    for (final key in _sectionKeys) {
      _sections[key] = TextEditingController();
    }
    _consultationId = widget.consultationId;
    _loadOrCreate();
  }

  static const _sectionKeys = [
    'chiefComplaint',
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
    setState(() => _consultationId = id);
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
            complete
                ? 'Encounter completed${clinical.api != null ? ' and synced' : ''}'
                : 'Saved locally',
          ),
        ),
      );
      Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Encounter'),
        actions: [
          if (ref.featureEnabled(FeatureFlagKeys.voiceDictation))
            IconButton(
              icon: Icon(_listening ? Icons.mic : Icons.mic_none),
              onPressed: () => _toggleVoice('historyOfPresentIllness'),
            ),
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _generatePdf),
          IconButton(icon: const Icon(Icons.save), onPressed: () => _save()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ref.featureEnabled(FeatureFlagKeys.icd11))
            TextField(
              decoration: const InputDecoration(
                labelText: 'ICD-11 search',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _searchIcd11,
            ),
          if (_selectedIcd11 != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Chip(label: Text('Diagnosis: $_selectedIcd11')),
            ),
          if (_edliz.isNotEmpty && ref.featureEnabled(FeatureFlagKeys.edliz)) ...[
            const Text('EDLIZ Suggestions'),
            ..._edliz.map(
              (e) => ListTile(
                title: Text(e.firstLine),
                subtitle: Text(
                  [e.alternative, e.dosage, e.formulation]
                      .whereType<String>()
                      .join(' · '),
                ),
              ),
            ),
            const Divider(),
          ],
          ..._sectionKeys.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _sections[key],
                maxLines: key.contains('History') || key.contains('Notes') ? 4 : 2,
                decoration: InputDecoration(
                  labelText: _labelFor(key),
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => _save(complete: true),
            child: const Text('Complete Encounter'),
          ),
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
