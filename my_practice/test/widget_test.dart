import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_practice/app.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';

void main() {
  testWidgets('MyPractice app smoke test', (WidgetTester tester) async {
    final db = AppDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MyPracticeApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.textContaining('MyPractice'), findsWidgets);
  });
}
