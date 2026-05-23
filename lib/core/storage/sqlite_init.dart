import 'package:smarthealth_shep/core/storage/app_database.dart';

/// Opens the SQLite database required for offline provider storage.
Future<void> initSqlite() async {
  await AppDatabase.instance.database;
}
