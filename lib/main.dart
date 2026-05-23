import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/app.dart';
import 'package:smarthealth_shep/core/storage/hive_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(
    const ProviderScope(
      child: SmartHealthApp(),
    ),
  );
}
