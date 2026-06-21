import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/remote/facility_api_client.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

final featureFlagsProvider =
    AsyncNotifierProvider<FeatureFlagsNotifier, Map<String, bool>>(
  FeatureFlagsNotifier.new,
);

class FeatureFlagsNotifier extends AsyncNotifier<Map<String, bool>> {
  @override
  Future<Map<String, bool>> build() async {
    final defaults = {
      for (final k in FeatureFlagKeys.all) k: _defaultFor(k),
    };

    if (MyPracticeConfig.devMode) {
      return defaults;
    }

    try {
      final dio = ref.read(dioProvider);
      final client = CatalogApiClient(dio);
      final remote = await client.getFeatureFlags();
      return {...defaults, ...remote};
    } catch (_) {
      return defaults;
    }
  }

  bool isEnabled(String key) => state.value?[key] ?? _defaultFor(key);

  bool _defaultFor(String key) {
    return switch (key) {
      FeatureFlagKeys.voiceDictation => true,
      FeatureFlagKeys.edliz => true,
      FeatureFlagKeys.icd11 => true,
      FeatureFlagKeys.claimsModule => MyPracticeConfig.devMode,
      _ => false,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> cacheToDb(AppDatabase db, Map<String, bool> flags) async {
    final now = DateTime.now().toUtc();
    for (final entry in flags.entries) {
      await db.into(db.featureFlags).insertOnConflictUpdate(
            FeatureFlagsCompanion.insert(
              key: entry.key,
              enabled: Value(entry.value),
              updatedAt: now,
            ),
          );
    }
  }
}

extension FeatureFlagsX on WidgetRef {
  bool featureEnabled(String key) =>
      watch(featureFlagsProvider).value?[key] ?? false;
}
