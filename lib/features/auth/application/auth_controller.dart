import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_preferences.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/app_user.dart';
import '../data/mock_auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final localPreferencesProvider = Provider<LocalPreferences>((ref) {
  return LocalPreferences();
});

final authRepositoryProvider = Provider<MockAuthRepository>((ref) {
  return MockAuthRepository(
    tokenStorage: ref.watch(tokenStorageProvider),
    localPreferences: ref.watch(localPreferencesProvider),
  );
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authRepositoryProvider));
  },
);

class AuthState {
  const AuthState({
    this.bootstrapped = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  final bool bootstrapped;
  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? bootstrapped,
    bool? isLoading,
    AppUser? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      bootstrapped: bootstrapped ?? this.bootstrapped,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState()) {
    bootstrap();
  }

  final MockAuthRepository _repository;

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final user = await _repository.bootstrapUser();
    state = state.copyWith(
      bootstrapped: true,
      isLoading: false,
      user: user,
      clearError: true,
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      return true;
    } on StateError catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        clearUser: true,
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      return true;
    } on StateError catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        clearUser: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.logout();
    state = state.copyWith(isLoading: false, clearUser: true, clearError: true);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}
