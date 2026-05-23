import 'package:mockito/annotations.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/shared/data/local/provider_dao.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_service.dart';

@GenerateMocks([
  ProviderDao,
  ApiService,
  SyncService,
])
void main() {}
