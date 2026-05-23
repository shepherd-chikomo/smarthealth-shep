import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Provider list returned by repository queries.
class ProvidersQueryResult {
  const ProvidersQueryResult({
    required this.providers,
    required this.isOffline,
  });

  final List<ProviderModel> providers;
  final bool isOffline;
}

/// Single provider returned by [ProviderRepository.getProviderById].
class ProviderDetailQueryResult {
  const ProviderDetailQueryResult({
    required this.provider,
    required this.isOffline,
    required this.fromCache,
  });

  final ProviderModel provider;
  final bool isOffline;
  final bool fromCache;
}
