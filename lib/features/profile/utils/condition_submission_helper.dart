import 'package:smarthealth_shep/core/network/api_service.dart';

/// Sends user-typed condition labels to the admin review queue.
Future<void> submitCustomConditionProposals({
  required ApiService api,
  required Map<String, String> customLabels,
  String? familyMemberId,
}) async {
  for (final label in customLabels.values) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) continue;
    try {
      await api.submitConditionProposal(
        trimmed,
        familyMemberId: familyMemberId,
      );
    } catch (_) {
      // Best-effort; profile data is already saved locally.
    }
  }
}
