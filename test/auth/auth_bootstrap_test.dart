import 'package:flutter_test/flutter_test.dart';
import 'package:noccaro_app/core/storage/local_preferences.dart';
import 'package:noccaro_app/features/auth/application/auth_controller.dart';
import 'package:noccaro_app/features/auth/data/mock_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/in_memory_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth bootstrap', () {
    test('restores user from token and local preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final tokenStorage = InMemoryTokenStorage();
      final localPreferences = LocalPreferences();
      final repository = MockAuthRepository(
        tokenStorage: tokenStorage,
        localPreferences: localPreferences,
      );

      final firstController = AuthController(repository);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await firstController.register(
        email: 'alice@example.com',
        password: 'password123',
        displayName: 'Alice',
      );
      final savedUser = firstController.state.user;
      expect(savedUser, isNotNull);

      final secondController = AuthController(repository);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(secondController.state.bootstrapped, isTrue);
      expect(secondController.state.user?.email, 'alice@example.com');
      expect(secondController.state.user?.displayName, 'Alice');
    });

    test('returns unauthenticated when no token exists', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MockAuthRepository(
        tokenStorage: InMemoryTokenStorage(),
        localPreferences: LocalPreferences(),
      );

      final controller = AuthController(repository);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.state.bootstrapped, isTrue);
      expect(controller.state.user, isNull);
      expect(controller.state.isAuthenticated, isFalse);
    });
  });
}
