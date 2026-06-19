import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/design_system/previews/clinical_previews.dart';
import 'package:my_practice/design_system/previews/dashboard_preview.dart';
import 'package:my_practice/design_system/previews/operations_previews.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Design Review Center — Phase 1 previews only (does not modify production pages).
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  int _selected = 0;

  static const _previews = <(String, Widget)>[
    ('Dashboard', DashboardPreview()),
    ('Patient Profile', PatientProfilePreview()),
    ('Clinical Encounter', EncounterPreview()),
    ('Patient Queue', QueuePreview()),
    ('Patients Directory', PatientsDirectoryPreview()),
    ('Claims & Medical Aid', ClaimsPreview()),
    ('Finance', FinancePreview()),
    ('Facility Management', FacilityPreview()),
    ('Calendar', CalendarPreview()),
    ('Prescriptions', PrescriptionsPreview()),
    ('Practitioner Earnings', EarningsPreview()),
    ('Reports', ReportsPreview()),
    ('Mobile View', MobilePreview()),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width > 1100,
              minExtendedWidth: 220,
              selectedIndex: _selected,
              onDestinationSelected: (i) => setState(() => _selected = i),
              leading: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Icon(Icons.palette_outlined, size: 28),
                    const SizedBox(height: 8),
                    Text('Design\nReview',
                        textAlign: TextAlign.center,
                        style: PracticeDesignTokens.inter(
                          size: 11,
                          weight: FontWeight.w600,
                        )),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/design-system'),
                      child: const Text('Design System'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('Production App'),
                    ),
                  ],
                ),
              ),
              destinations: [
                for (final p in _previews)
                  NavigationRailDestination(
                    icon: const Icon(Icons.art_track_outlined),
                    selectedIcon: const Icon(Icons.art_track),
                    label: Text(p.$1),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            'Preview: ${_previews[_selected].$1}',
                            style: PracticeDesignTokens.sectionTitle(context),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PHASE 1 — AWAITING APPROVAL',
                              style: PracticeDesignTokens.inter(
                                size: 10,
                                weight: FontWeight.w700,
                                color: Colors.amber.shade200,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Production pages unchanged',
                            style: PracticeDesignTokens.metadata(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: _previews[_selected].$2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
