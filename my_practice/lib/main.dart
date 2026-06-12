import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/app.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MyPracticeApp(),
    ),
  );
}
