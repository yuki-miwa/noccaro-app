import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noccaro_app/app/app.dart';
import 'package:noccaro_app/features/auth/application/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/in_memory_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to login when no session exists', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        ],
        child: const NoccaroApp(),
      ),
    );

    await _pumpUntilFound(tester, find.text('ログイン'));

    expect(find.text('ログイン'), findsWidgets);
    expect(find.text('新規登録へ'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for target widget');
}
