import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/theme/app_theme.dart';
import 'package:smarthealth_shep/features/design_system/design_system_demo_screen.dart';

void main() {
  testWidgets('Material 3 theme renders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(child: Text('SmartHealth')),
          ),
        ),
      ),
    );
    expect(find.text('SmartHealth'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Design system demo shows card, button, and pulse', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DesignSystemDemoScreen(),
        ),
      ),
    );

    expect(find.text('Healthcare directory'), findsOneWidget);
    expect(find.text('Primary action'), findsOneWidget);
    expect(find.byIcon(Icons.emergency), findsOneWidget);
  });
}
