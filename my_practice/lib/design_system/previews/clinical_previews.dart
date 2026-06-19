import 'package:flutter/material.dart';
import 'package:my_practice/design_system/data/preview_seed_data.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/design_system/widgets/practice_preview_shell.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class PatientProfilePreview extends StatelessWidget {
  const PatientProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 3,
      title: 'Patient Record',
      subtitle: 'Tatenda Gumbo · SH-102341',
      child: DefaultTabController(
        length: 7,
        child: Column(
          children: [
            _PatientHeader(),
            TabBar(
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Medical History'),
                Tab(text: 'Encounters'),
                Tab(text: 'Prescriptions'),
                Tab(text: 'Documents'),
                Tab(text: 'Billing'),
                Tab(text: 'Timeline'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(),
                  const Center(child: Text('Medical history')),
                  const Center(child: Text('Encounters')),
                  const Center(child: Text('Prescriptions')),
                  const Center(child: Text('Documents')),
                  const Center(child: Text('Billing')),
                  const Center(child: Text('Timeline')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Row(
        children: [
          const PracticeAvatar(initials: 'TG', size: 72),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tatenda Gumbo',
                    style: PracticeDesignTokens.pageTitle(context)),
                Text('SH-102341 · 23F · Cellmed',
                    style: PracticeDesignTokens.metadata(context)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: const [
                    PracticeStatusChip(label: 'Antenatal', tone: PracticeStatusTone.info),
                    PracticeStatusChip(label: 'No known allergies', tone: PracticeStatusTone.success),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.medical_services_outlined, size: 18),
            label: const Text('Start Encounter'),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth > 700 ? 2 : 1;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              _SummaryCard('Allergies', ['Penicillin (severe)']),
              _SummaryCard('Chronic Conditions', ['G2P1 · Previous SVD 2023']),
              _SummaryCard('Current Medications', ['Folic acid · Iron']),
              _SummaryCard('Recent Visits', ['Antenatal 11 Jun 2026']),
              _SummaryCard('Outstanding Balance', ['\$0.00']),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.title, this.items);

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PracticeDesignTokens.sectionTitle(context)),
          const SizedBox(height: 8),
          for (final i in items)
            Text('• $i', style: PracticeDesignTokens.clinicalNote(context)),
        ],
      ),
    );
  }
}

class EncounterPreview extends StatelessWidget {
  const EncounterPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 4,
      title: 'Clinical Encounter',
      subtitle: 'Tatenda Gumbo · SH-102341 · Antenatal · Started 09:18',
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.mic_none, size: 18),
          label: const Text('Voice'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Complete & Save'),
        ),
        const SizedBox(width: 12),
      ],
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 900) {
            return _EncounterMobileLayout();
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 260, child: _PatientSummaryPanel()),
              Expanded(child: _EncounterWorkspace()),
              SizedBox(width: 280, child: _ClinicalAssistPanel()),
            ],
          );
        },
      ),
    );
  }
}

class _EncounterMobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PatientSummaryPanel(),
          const SizedBox(height: 16),
          _EncounterWorkspace(),
          const SizedBox(height: 16),
          _ClinicalAssistPanel(),
        ],
      ),
    );
  }
}

class _PatientSummaryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Summary', style: PracticeDesignTokens.sectionTitle(context)),
          const SizedBox(height: 12),
          const PracticeAvatar(initials: 'TG', size: 48),
          const SizedBox(height: 8),
          Text('Tatenda Gumbo', style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
          Text('23F · Cellmed', style: PracticeDesignTokens.metadata(context)),
          const Divider(height: 24),
          Text('Vitals', style: PracticeDesignTokens.sectionTitle(context)),
          Text('BP 118/74 · P 82 · T 36.6°C',
              style: PracticeDesignTokens.clinicalNote(context)),
        ],
      ),
    );
  }
}

class _EncounterWorkspace extends StatelessWidget {
  static const sections = [
    ('Presenting Complaint',
        'Pregnant patient at 28 weeks GA — mild lower back pain and ankle swelling.'),
    ('History', 'G2P1, previous SVD 2023. No DM/HTN.'),
    ('Examination', 'BP 118/74, P 82. Fundal height 27cm. FH 142bpm.'),
    ('Investigations', 'Urinalysis: trace protein. Hb 11.2 g/dL.'),
    ('Assessment', 'Normal antenatal visit at 28 weeks.'),
    ('Treatment Plan', 'Continue iron and folate. Review in 2 weeks.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final s in sections)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: PracticeDesignTokens.previewCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1, style: PracticeDesignTokens.sectionTitle(context)),
                  const SizedBox(height: 8),
                  Text(s.$2, style: PracticeDesignTokens.clinicalNote(context)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClinicalAssistPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ICD-11', style: PracticeDesignTokens.sectionTitle(context)),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search diagnosis…',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),
                const PracticeStatusChip(label: 'JA24 — Normal pregnancy', tone: PracticeStatusTone.info),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EDLIZ', style: PracticeDesignTokens.sectionTitle(context)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.medication_outlined),
                  title: const Text('Ferrous sulphate 200mg'),
                  subtitle: const Text('1 tab OD · First line'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.medication_outlined),
                  title: const Text('Folic acid 5mg'),
                  subtitle: const Text('1 tab OD'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QueuePreview extends StatelessWidget {
  const QueuePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 2,
      title: 'Patient Queue',
      subtitle: 'Live triage and consultation flow',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QueueSection('Waiting', Icons.schedule, PreviewSeedData.queueWaiting, 'waiting'),
            _QueueSection('In Consultation', Icons.medical_services_outlined,
                PreviewSeedData.queueInConsult, 'in consult'),
          ],
        ),
      ),
    );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection(this.title, this.icon, this.patients, this.status);

  final String title;
  final IconData icon;
  final List<(String, String, String, String, String, String, String)> patients;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: PracticeDesignTokens.sectionTitle(context)),
            const SizedBox(width: 8),
            PracticeStatusChip(label: '${patients.length}', tone: PracticeStatusTone.neutral),
          ],
        ),
        const SizedBox(height: 12),
        for (final p in patients)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Row(
              children: [
                PracticeAvatar(initials: p.$1),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p.$2} · ${p.$3}',
                          style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
                      Text('${p.$4} · ${p.$5}',
                          style: PracticeDesignTokens.metadata(context)),
                      Text('Arrived ${p.$6} · ${p.$7}',
                          style: PracticeDesignTokens.metadata(context)),
                    ],
                  ),
                ),
                PracticeStatusChip(
                  label: status,
                  tone: PracticeStatusChip.toneForClaimStatus(status),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class PatientsDirectoryPreview extends StatelessWidget {
  const PatientsDirectoryPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticePreviewShell(
      selectedNavIndex: 3,
      title: 'Patient Directory',
      subtitle: '${PreviewSeedData.patients.length} patients registered',
      actions: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Patient'),
        ),
        const SizedBox(width: 12),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by SmartHealth ID, name, national ID…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list, size: 16),
                        label: const Text('Filters'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: PracticeDesignTokens.previewCardDecoration(context),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          for (final h in ['PATIENT', 'SMARTHEALTH ID', 'AGE / SEX', 'INSURER', 'PHONE', 'LAST VISIT'])
                            Expanded(
                              flex: h == 'PATIENT' ? 2 : 1,
                              child: Text(h, style: PracticeDesignTokens.tableHeader(context)),
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: context.appColors.border),
                    Expanded(
                      child: ListView.separated(
                        itemCount: PreviewSeedData.patients.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: context.appColors.border),
                        itemBuilder: (_, i) {
                          final p = PreviewSeedData.patients[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      PracticeAvatar(initials: p.$1, size: 32),
                                      const SizedBox(width: 8),
                                      Text(p.$2),
                                    ],
                                  ),
                                ),
                                Expanded(child: Text(p.$3, style: PracticeDesignTokens.metadata(context))),
                                Expanded(child: Text(p.$4)),
                                Expanded(
                                  child: PracticeStatusChip(
                                    label: p.$5,
                                    tone: PracticeStatusTone.info,
                                  ),
                                ),
                                Expanded(child: Text(p.$6, style: PracticeDesignTokens.metadata(context))),
                                Expanded(child: Text(p.$7, style: PracticeDesignTokens.metadata(context))),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
