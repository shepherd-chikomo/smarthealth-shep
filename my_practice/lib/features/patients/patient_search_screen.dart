import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class PatientSearchScreen extends ConsumerStatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  ConsumerState<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends ConsumerState<PatientSearchScreen> {
  final _queryCtrl = TextEditingController();
  List<Patient> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final results =
        await ref.read(patientRepositoryProvider).search(_queryCtrl.text);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text('Patients', style: PracticeDesignTokens.pageTitle(context)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            '${_results.length} patients',
            style: PracticeDesignTokens.metadata(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _queryCtrl,
            decoration: InputDecoration(
              hintText: 'Search by SmartHealth ID, name, national ID, phone…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _search,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Expanded(
          child: _results.isEmpty && !_loading
              ? const PracticeEmptyState(
                  title: 'No patients found',
                  message: 'Try a different search term.',
                  icon: Icons.person_search_outlined,
                )
              : wide
                  ? _PatientTable(results: _results)
                  : _PatientList(results: _results),
        ),
      ],
    );
  }
}

class _PatientTable extends StatelessWidget {
  const _PatientTable({required this.results});

  final List<Patient> results;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: PracticeDesignTokens.previewCardDecoration(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  for (final h in [
                    'PATIENT',
                    'SMARTHEALTH ID',
                    'AGE / SEX',
                    'INSURER',
                    'PHONE',
                  ])
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
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: context.appColors.border),
                itemBuilder: (_, i) => _PatientTableRow(patient: results[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientTableRow extends StatelessWidget {
  const _PatientTableRow({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/patients/${patient.id}/chart'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  PracticeAvatar(
                    initials: PatientFormatters.initials(patient),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(PatientFormatters.fullName(patient))),
                ],
              ),
            ),
            Expanded(
              child: Text(
                patient.smarthealthPatientId ?? '—',
                style: PracticeDesignTokens.metadata(context),
              ),
            ),
            Expanded(child: Text(PatientFormatters.ageSex(patient))),
            Expanded(
              child: PracticeStatusChip(
                label: PatientFormatters.insurerLabel(patient.insuranceInfo),
                tone: PracticeStatusTone.info,
              ),
            ),
            Expanded(
              child: Text(
                patient.phone ?? '—',
                style: PracticeDesignTokens.metadata(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientList extends StatelessWidget {
  const _PatientList({required this.results});

  final List<Patient> results;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = results[i];
        return InkWell(
          onTap: () => context.push('/patients/${p.id}/chart'),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: PracticeDesignTokens.previewCardDecoration(context),
            child: Row(
              children: [
                PracticeAvatar(initials: PatientFormatters.initials(p)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PatientFormatters.fullName(p),
                        style: PracticeDesignTokens.inter(weight: FontWeight.w600),
                      ),
                      Text(
                        [
                          if (p.smarthealthPatientId != null) p.smarthealthPatientId,
                          PatientFormatters.ageSex(p),
                          PatientFormatters.insurerLabel(p.insuranceInfo),
                        ].join(' · '),
                        style: PracticeDesignTokens.metadata(context),
                      ),
                      if (p.phone != null)
                        Text(p.phone!, style: PracticeDesignTokens.metadata(context)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}
