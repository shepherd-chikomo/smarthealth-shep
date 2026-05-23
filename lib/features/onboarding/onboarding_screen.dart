import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth_shep/core/assets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const completedKey = 'onboarding_completed';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = <({String asset, String titleKey, String bodyKey})>[
    (
      asset: AppAssets.onboardingFindDoctors,
      titleKey: 'findDoctors',
      bodyKey: 'findDoctorsBody',
    ),
    (
      asset: AppAssets.onboardingBookAppointments,
      titleKey: 'bookAppointments',
      bodyKey: 'bookAppointmentsBody',
    ),
    (
      asset: AppAssets.onboardingEmergencyHelp,
      titleKey: 'emergencyHelp',
      bodyKey: 'emergencyHelpBody',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.completedKey, true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = _copyFor(l10n);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final text = copy[slide.titleKey]!;
                  final body = copy[slide.bodyKey]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            slide.asset,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: HomeDashboardColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: HomeDashboardColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == index
                        ? HomeDashboardColors.primary
                        : HomeDashboardColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_index == _slides.length - 1) {
                      _finish();
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeDashboardColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    _index == _slides.length - 1
                        ? l10n.onboardingGetStarted
                        : l10n.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _copyFor(AppLocalizations l10n) => {
        'findDoctors': l10n.onboardingFindDoctorsTitle,
        'findDoctorsBody': l10n.onboardingFindDoctorsBody,
        'bookAppointments': l10n.onboardingBookAppointmentsTitle,
        'bookAppointmentsBody': l10n.onboardingBookAppointmentsBody,
        'emergencyHelp': l10n.onboardingEmergencyHelpTitle,
        'emergencyHelpBody': l10n.onboardingEmergencyHelpBody,
      };
}
