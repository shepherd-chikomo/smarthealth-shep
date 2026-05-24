/// External URLs for facility/provider workflows (not part of patient app UX).
abstract final class PortalConfig {
  /// Base URL for the facility claim portal (Next.js `/claim` route).
  static const String claimPortalBase = String.fromEnvironment(
    'FACILITY_CLAIM_PORTAL_URL',
    defaultValue: 'http://localhost:3001/claim',
  );

  static String claimUrl({
    required String type,
    required String targetId,
  }) {
    final base = claimPortalBase.replaceAll(RegExp(r'/$'), '');
    return '$base?type=$type&targetId=$targetId';
  }
}
