import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/features/claim/widgets/claimable_facilities_list.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class ClaimHubScreen extends ConsumerStatefulWidget {
  const ClaimHubScreen({super.key});

  @override
  ConsumerState<ClaimHubScreen> createState() => _ClaimHubScreenState();
}

class _ClaimHubScreenState extends ConsumerState<ClaimHubScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabs;

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final signedIn = auth.status == AuthStatus.authenticated ||
        auth.status == AuthStatus.needsFacility;
    final hasClaimable = (auth.profile?.linkedFacilities ?? [])
        .any((f) => f.canClaimOwnership || f.isOwnedByMe);

    if (signedIn && hasClaimable) {
      _tabs ??= TabController(length: 2, vsync: this);
      return Scaffold(
        appBar: practiceMoreAppBar(
          context,
          'Claim facilities',
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Claim facilities'),
              Tab(text: 'Other options'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            ClaimableFacilitiesList(
              onFacilityOpened: () {
                if (context.mounted) Navigator.maybePop(context);
              },
            ),
            _ClaimOptionsList(showSignInLink: false),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Claim access')),
      body: _ClaimOptionsList(showSignInLink: !signedIn),
    );
  }
}

class _ClaimOptionsList extends StatelessWidget {
  const _ClaimOptionsList({required this.showSignInLink});

  final bool showSignInLink;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Get started with MyPractice',
          style: AppTextStyles.xl(fontWeight: AppTextStyles.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how to verify your identity and claim facilities.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
        const SizedBox(height: 24),
        _OptionCard(
          icon: Icons.verified_user_outlined,
          title: 'Registry email claim',
          subtitle:
              'Match your MDPCZ registry email, verify with OTP, claim your practitioner profile and linked facilities instantly.',
          buttonLabel: 'Claim with registry email',
          onTap: () => context.push('/claim/registry'),
        ),
        const SizedBox(height: 12),
        _OptionCard(
          icon: Icons.upload_file_outlined,
          title: 'Manual listing claim',
          subtitle:
              'Search for a facility or practitioner listing, upload proof documents, and submit for SmartHealth review.',
          buttonLabel: 'Manual claim wizard',
          onTap: () => context.push('/claim/manual'),
        ),
        const SizedBox(height: 12),
        _OptionCard(
          icon: Icons.badge_outlined,
          title: 'MDPCZ registration lookup',
          subtitle:
              'Not matched by email? Validate with your registration number and request manual verification.',
          buttonLabel: 'Registration validation',
          onTap: () => context.push('/claim/validation'),
        ),
        if (showSignInLink) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Already have access? Sign in'),
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTheme.themedCard(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.sm(color: context.appColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onTap, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
