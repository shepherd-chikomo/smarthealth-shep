import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/domain/models/portal_profile.dart';
import 'package:my_practice/features/claim/widgets/claimable_facility_card.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

/// Registry-linked facilities the practitioner can claim (HPA role-holder sites).
class ClaimableFacilitiesList extends ConsumerStatefulWidget {
  const ClaimableFacilitiesList({
    super.key,
    this.onFacilityOpened,
    this.embedded = false,
  });

  final VoidCallback? onFacilityOpened;

  /// When true, returns sliver children for embedding in a parent [CustomScrollView].
  final bool embedded;

  @override
  ConsumerState<ClaimableFacilitiesList> createState() =>
      _ClaimableFacilitiesListState();
}

class _ClaimableFacilitiesListState extends ConsumerState<ClaimableFacilitiesList> {
  String? _claimingId;
  String? _error;

  List<LinkedFacility> get _claimable {
    final linked = ref.watch(authStateProvider).profile?.linkedFacilities ?? [];
    return linked
        .where((f) => f.canClaimOwnership || f.isOwnedByMe)
        .toList();
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
      widget.onFacilityOpened?.call();
      if (mounted) context.go('/dashboard');
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
      widget.onFacilityOpened?.call();
      if (mounted) context.go('/dashboard');
      return;
    }
    setState(
      () => _error =
          'Facility is owned but not active yet. Try claiming again or refresh.',
    );
  }

  List<Widget> _contentChildren(BuildContext context) {
    final claimable = _claimable;
    if (claimable.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No unclaimed registry-linked facilities for your profile. '
            'Use the other claim options if you need to add a new site.',
            style: AppTextStyles.sm(color: context.appColors.mutedForeground),
          ),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Text(
          'Claim each site where you are the HPA role-holder, then open it in MyPractice.',
          style: AppTextStyles.sm(color: context.appColors.mutedForeground),
        ),
      ),
      for (final f in claimable)
        ClaimableFacilityCard(
          facility: f,
          claiming: _claimingId == f.id,
          onClaim: () => _claimAndOpen(f),
          onOpenOwned: () => _openOwned(f),
        ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _contentChildren(context),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: _contentChildren(context),
    );
  }
}

/// Claimable facility rows for embedding in another scroll view (e.g. facility picker).
List<Widget> buildClaimableFacilitySection(
  BuildContext context, {
  required List<LinkedFacility> claimable,
  required String? claimingId,
  required String? error,
  required void Function(LinkedFacility f) onClaim,
  required void Function(LinkedFacility f) onOpenOwned,
  String sectionTitle = 'More linked facilities',
}) {
  if (claimable.isEmpty) return [];

  return [
    const SizedBox(height: 8),
    Text(
      sectionTitle,
      style: AppTextStyles.sm(fontWeight: AppTextStyles.semibold),
    ),
    const SizedBox(height: 4),
    Text(
      'Claim each site where you are the HPA role-holder, then open it in MyPractice.',
      style: AppTextStyles.sm(color: context.appColors.mutedForeground),
    ),
    const SizedBox(height: 8),
    for (final f in claimable)
      ClaimableFacilityCard(
        facility: f,
        claiming: claimingId == f.id,
        onClaim: () => onClaim(f),
        onOpenOwned: () => onOpenOwned(f),
      ),
    if (error != null) ...[
      const SizedBox(height: 8),
      Text(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ],
  ];
}
