import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Default HTTP cache policy — aggressive caching for low-bandwidth use.
CacheOptions defaultCacheOptions({required CacheStore store}) {
  return CacheOptions(
    store: store,
    policy: CachePolicy.request,
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
  );
}
