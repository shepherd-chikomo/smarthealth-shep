import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class FacilityPickerScreen extends ConsumerStatefulWidget {
  const FacilityPickerScreen({super.key});

  @override
  ConsumerState<FacilityPickerScreen> createState() =>
      _FacilityPickerScreenState();
}

class _FacilityPickerScreenState extends ConsumerState<FacilityPickerScreen> {
  String? _claimingId;
  String? _error;
  bool _refreshing = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refreshProfile);
  }

  Future<void> _refreshProfile() async {
    final existing = ref.read(authStateProvider).profile;
    if (existing == null) {
      await ref.read(authStateProvider.notifier).loadProfile();
    }
    final auth = ref.read(authStateProvider);
    final profile = auth.profile;
    if (profile != null &&
        profile.provider != null &&
        profile.linkedFacilities.isEmpty) {
      try {
        final linked =
            await ref.read(claimsApiClientProvider).myPrimaryFacilities();
        ref.read(authStateProvider.notifier).mergeLinkedFacilities(linked);
      } catch (_) {}
    }
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _selectMembership(FacilityMembership f) async {
    setState(() => _error = null);
    await ref.read(authStateProvider.notifier).selectFacility(f.id);
    if (!mounted) return;
    context.go('/dashboard');
  }

  Future<void> _claimAndOpen(LinkedFacility f) async {
    setState(() {
      _claimingId = f.id;
      _error = null;
    });
    try {
      await ref.read(claimsApiClientProvider).instantClaimFacility(f.id);
      await ref.read(authStateProvider.notifier).loadProfile();
      await ref.read(authStateProvider.notifier).selectFacility(f.id);
      if (!mounted) return;
      context.go('/dashboard');
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e) ?? 'Could not claim facility');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _claimingId = null);
    }
  }

  Future<void> _openOwned(LinkedFacility f) async {
    setState(() => _error = null);
    await ref.read(authStateProvider.notifier).loadProfile();
    final auth = ref.read(authStateProvider);
    final matches =
        auth.profile?.facilities.where((m) => m.id == f.id).toList() ?? [];
    if (matches.isNotEmpty) {
      await ref.read(authStateProvider.notifier).selectFacility(matches.first.id);
      if (!mounted) return;
      context.go('/dashboard');
      return;
    }
    setState(
      () => _error =
          'Facility is owned but not active yet. Try claiming again or refresh.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final profile = auth.profile;
    final memberships = profile?.facilities ?? [];
    final linked = profile?.linkedFacilities ?? [];
    final provider = profile?.provider;

    return Scaffold(
      appBar: AppBar(title: const Text('Your facilities')),
      body: _refreshing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (provider != null) ...[
            Text(
              provider.name,
              style: AppTextStyles.lg(fontWeight: AppTextStyles.bold),
            ),
            if (provider.specialty != null)
              Text(
                provider.specialty!,
                style: AppTextStyles.sm(
                  color: context.appColors.mutedForeground,
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (memberships.isNotEmpty) ...[
            Text(
              'Active facilities',
              style: AppTextStyles.sm(fontWeight: AppTextStyles.semibold),
            ),
            const SizedBox(height: 8),
            ...memberships.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppTheme.themedCard(
                  context: context,
                  child: ListTile(
                    title: Text(f.name),
                    subtitle: Text(f.role),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectMembership(f),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (linked.isNotEmpty) ...[
            Text(
              memberships.isEmpty
                  ? 'Registry-linked facilities'
                  : 'More linked facilities',
              style: AppTextStyles.sm(fontWeight: AppTextStyles.semibold),
            ),
            const SizedBox(height: 4),
            Text(
              'Claim each site where you are the HPA role-holder, then open it in MyPractice.',
              style: AppTextStyles.sm(
                color: context.appColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            ...linked.map((f) => _linkedFacilityCard(f)),
          ],
          if (memberships.isEmpty && linked.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  Text(
                    auth.error ??
                        'No facilities linked to your account yet.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sm(
                      color: context.appColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/claim'),
                    child: const Text('Open claim wizard'),
                  ),
                ],
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _linkedFacilityCard(LinkedFacility f) {
    final claiming = _claimingId == f.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppTheme.themedCard(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(f.name, style: AppTextStyles.base(fontWeight: AppTextStyles.bold)),
              if (f.city != null)
                Text(
                  f.city!,
                  style: AppTextStyles.sm(
                    color: context.appColors.mutedForeground,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                f.statusLabel,
                style: AppTextStyles.xs(
                  color: context.appColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              if (f.isOwnedByMe)
                FilledButton(
                  onPressed: claiming ? null : () => _openOwned(f),
                  child: const Text('Open facility'),
                )
              else if (f.canClaimOwnership)
                FilledButton(
                  onPressed: claiming ? null : () => _claimAndOpen(f),
                  child: claiming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Claim ownership'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
