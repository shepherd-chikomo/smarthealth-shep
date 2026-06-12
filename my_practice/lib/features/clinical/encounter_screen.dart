import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/core/feature_flags/feature_flags_notifier.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/features/clinical/pdf_service.dart';
import 'package:my_practice/features/clinical/voice_dictation_service.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class EncounterScreen extends ConsumerStatefulWidget {
  const EncounterScreen({
    super.key,
    required this.patientId,
    this.consultationId,
  });

  final String patientId;
  final String? consultationId;

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  final _sections = <String, TextEditingController>{};
  String? _consultationId;
  String? _selectedIcd11;
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
    if (_consultationId != null) {
      final existing = await (db.select(db.consultations)
            ..where((t) => t.id.equals(_consultationId!)))
          .getSingleOrNull();
      if (existing != null) {
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
        setState(() {});
      }
      return;
    }

    final id = _uuid.v4();
    final facilityId = ref.read(facilityIdProvider) ?? 'seed-facility-001';
    await db.into(db.consultations).insert(
          ConsultationsCompanion.insert(
            id: id,
            facilityId: facilityId,
            providerId: 'seed-provider-001',
            patientId: widget.patientId,
            startedAt: Value(DateTime.now().toUtc()),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    setState(() => _consultationId = id);
  }

  Future<void> _save({bool complete = false}) async {
    final db = ref.read(appDatabaseProvider);
    final id = _consultationId!;
    await (db.update(db.consultations)..where((t) => t.id.equals(id))).write(
          ConsultationsCompanion(
            chiefComplaint: Value(_sections['chiefComplaint']!.text),
            historyOfPresentIllness:
                Value(_sections['historyOfPresentIllness']!.text),
            pastMedicalHistory: Value(_sections['pastMedicalHistory']!.text),
            surgicalHistory: Value(_sections['surgicalHistory']!.text),
            familyHistory: Value(_sections['familyHistory']!.text),
            socialHistory: Value(_sections['socialHistory']!.text),
            examinationNotes: Value(_sections['examinationNotes']!.text),
            assessment: Value(_sections['assessment']!.text),
            plan: Value(_sections['plan']!.text),
            followUpPlan: Value(_sections['followUpPlan']!.text),
            status: Value(complete ? 'completed' : 'in_progress'),
            completedAt: complete ? Value(DateTime.now().toUtc()) : const Value(null),
            updatedAt: Value(DateTime.now().toUtc()),
            syncStatus: const Value('pending'),
          ),
        );
    if (complete && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encounter completed — sync queued')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _searchIcd11(String q) async {
    if (!ref.featureEnabled(FeatureFlagKeys.icd11)) return;
    final db = ref.read(appDatabaseProvider);
    final results = await (db.select(db.icd11Codes)
          ..where(
            (t) =>
                t.code.like('%$q%') | t.description.like('%$q%'),
          )
          ..limit(10))
        .get();
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
    setState(() => _selectedIcd11 = picked.code);
    _sections['assessment']!.text =
        '${_sections['assessment']!.text}\n${picked.code}: ${picked.description}'
            .trim();

    if (ref.featureEnabled(FeatureFlagKeys.edliz)) {
      final edliz = await (db.select(db.edlizRecommendations)
            ..where((t) => t.icd11Code.equals(picked.code)))
          .get();
      setState(() => _edliz = edliz);
    }
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
