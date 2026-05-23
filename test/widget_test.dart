import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/theme/app_theme.dart';

void main() {
  testWidgets('Material 3 theme renders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Center(child: Text('SmartHealth')),
          ),
        ),
      ),
    );
    expect(find.text('SmartHealth'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
