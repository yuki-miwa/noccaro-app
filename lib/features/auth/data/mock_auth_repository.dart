import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/storage/local_preferences.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/app_user.dart';

class MockAuthRepository {
  MockAuthRepository({
    required TokenStorage tokenStorage,
    required LocalPreferences localPreferences,
  }) : _tokenStorage = tokenStorage,
       _localPreferences = localPreferences;

  final TokenStorage _tokenStorage;
  final LocalPreferences _localPreferences;

  static final Map<String, AppUser> _usersByEmail = {};
  static final Map<String, String> _passwordByEmail = {};

  Future<AppUser?> bootstrapUser() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final user = await _localPreferences.loadUser();
    if (user == null) {
      await _tokenStorage.clearToken();
      return null;
    }

    _usersByEmail[user.email.toLowerCase()] = user;
    return user;
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || password.isEmpty || displayName.isEmpty) {
      throw StateError('登録情報が不足しています。');
    }
    if (password.length < 6) {
      throw StateError('パスワードは6文字以上必要です。');
    }
    if (_usersByEmail.containsKey(normalizedEmail)) {
      throw StateError('このメールアドレスは既に利用されています。');
    }

    final user = AppUser(
      id: const Uuid().v4(),
      email: normalizedEmail,
      displayName: displayName.trim(),
    );

    _usersByEmail[normalizedEmail] = user;
    _passwordByEmail[normalizedEmail] = password;
    await _persistLogin(user);

    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final normalizedEmail = email.trim().toLowerCase();

    final user = _usersByEmail[normalizedEmail];
    if (user == null) {
      throw StateError('ユーザーが見つかりません。先に新規登録してください。');
    }

    if (_passwordByEmail[normalizedEmail] != password) {
      throw StateError('メールアドレスまたはパスワードが正しくありません。');
    }

    await _persistLogin(user);
    return user;
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _localPreferences.clearSessionState();
  }

  Future<void> _persistLogin(AppUser user) async {
    await _tokenStorage.writeToken('mock-token-${user.id}');
    await _localPreferences.saveUser(user);
  }
}
