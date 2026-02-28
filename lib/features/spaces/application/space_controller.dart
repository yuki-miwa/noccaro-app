import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../../shared/models/membership.dart';
import '../../../shared/models/space.dart';
import '../data/mock_space_repository.dart';

final spaceRepositoryProvider = Provider<MockSpaceRepository>((ref) {
  return MockSpaceRepository(
    localPreferences: ref.watch(localPreferencesProvider),
  );
});

final spaceControllerProvider =
    StateNotifierProvider<SpaceController, SpaceState>((ref) {
      return SpaceController(
        repository: ref.watch(spaceRepositoryProvider),
        ref: ref,
      );
    });

class SpaceState {
  const SpaceState({
    this.bootstrapped = false,
    this.isLoading = false,
    this.currentSpace,
    this.membership,
    this.errorMessage,
  });

  final bool bootstrapped;
  final bool isLoading;
  final Space? currentSpace;
  final SpaceMembership? membership;
  final String? errorMessage;

  SpaceState copyWith({
    bool? bootstrapped,
    bool? isLoading,
    Space? currentSpace,
    bool clearSpace = false,
    SpaceMembership? membership,
    bool clearMembership = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SpaceState(
      bootstrapped: bootstrapped ?? this.bootstrapped,
      isLoading: isLoading ?? this.isLoading,
      currentSpace: clearSpace ? null : currentSpace ?? this.currentSpace,
      membership: clearMembership ? null : membership ?? this.membership,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SpaceController extends StateNotifier<SpaceState> {
  SpaceController({required MockSpaceRepository repository, required Ref ref})
    : _repository = repository,
      _ref = ref,
      super(const SpaceState()) {
    _listenAuth();
    bootstrap();
  }

  final MockSpaceRepository _repository;
  final Ref _ref;

  void _listenAuth() {
    _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = state.copyWith(
          bootstrapped: true,
          isLoading: false,
          clearMembership: true,
          clearSpace: true,
          clearError: true,
        );
      }
    });
  }

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final authState = _ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      state = state.copyWith(
        bootstrapped: true,
        isLoading: false,
        clearSpace: true,
        clearMembership: true,
      );
      return;
    }

    final space = await _repository.loadCurrentSpace();
    final membership = await _repository.loadMembership();

    state = state.copyWith(
      bootstrapped: true,
      isLoading: false,
      currentSpace: space,
      membership: membership,
      clearError: true,
    );
  }

  Future<bool> joinByCode(String spaceCode) async {
    final authState = _ref.read(authControllerProvider);
    final user = authState.user;
    if (user == null) {
      state = state.copyWith(errorMessage: '先にログインしてください。');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.joinByCode(
        spaceCode: spaceCode,
        userId: user.id,
      );
      state = state.copyWith(
        isLoading: false,
        currentSpace: result.space,
        membership: result.membership,
        clearError: true,
      );
      return true;
    } on StateError catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }

  Future<void> approvePendingForDemo() async {
    final membership = state.membership;
    if (membership == null) {
      return;
    }
    final updated = await _repository.updateMembershipStatus(
      current: membership,
      status: MembershipStatus.active,
    );
    state = state.copyWith(membership: updated);
  }

  Future<void> setMembershipStatusForDemo(MembershipStatus status) async {
    final membership = state.membership;
    if (membership == null) {
      return;
    }

    final updated = await _repository.updateMembershipStatus(
      current: membership,
      status: status,
      suspendedUntil: status == MembershipStatus.suspended
          ? DateTime.now().add(const Duration(hours: 2))
          : null,
    );

    state = state.copyWith(membership: updated);
  }

  Future<void> clearForLogout() async {
    await _repository.clear();
    state = state.copyWith(
      clearSpace: true,
      clearMembership: true,
      clearError: true,
      bootstrapped: true,
      isLoading: false,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}
