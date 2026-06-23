import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/data/repositories/repositories.dart';

final credentialsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(facilityRepositoryProvider).getCredentials();
});

final messagesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(facilityRepositoryProvider).getMessages();
});
