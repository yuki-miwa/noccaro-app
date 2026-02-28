import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/membership.dart';
import '../../../shared/models/report.dart';
import '../../../shared/models/whisper.dart';
import '../data/mock_whispers_repository.dart';

enum LocationPermissionState { unknown, denied, granted }

final whispersRepositoryProvider = Provider<MockWhispersRepository>((ref) {
  return MockWhispersRepository();
});

final whispersControllerProvider =
    StateNotifierProvider<WhispersController, WhispersState>((ref) {
      return WhispersController(ref.watch(whispersRepositoryProvider));
    });

class WhispersState {
  const WhispersState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.permission = LocationPermissionState.unknown,
    this.whispers = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final LocationPermissionState permission;
  final List<Whisper> whispers;
  final String? errorMessage;

  WhispersState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    LocationPermissionState? permission,
    List<Whisper>? whispers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WhispersState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      permission: permission ?? this.permission,
      whispers: whispers ?? this.whispers,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class WhispersController extends StateNotifier<WhispersState> {
  WhispersController(this._repository) : super(const WhispersState());

  final MockWhispersRepository _repository;

  Future<void> requestPermission() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    state = state.copyWith(permission: LocationPermissionState.granted);
  }

  void denyPermissionForDemo() {
    state = state.copyWith(permission: LocationPermissionState.denied);
  }

  Future<void> load({required SpaceMembership? membership}) async {
    if (membership == null || membership.status != MembershipStatus.active) {
      state = state.copyWith(whispers: const [], clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final whispers = await _repository.fetchWhispers();
      state = state.copyWith(
        isLoading: false,
        whispers: whispers,
        clearError: true,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ウィスパーの取得に失敗しました。',
      );
    }
  }

  Future<bool> create({
    required String body,
    required SpaceMembership? membership,
    required double exactLat,
    required double exactLng,
    int gridMeters = 120,
  }) async {
    if (membership == null || membership.status != MembershipStatus.active) {
      state = state.copyWith(errorMessage: '現在は投稿できません。');
      return false;
    }
    if (state.permission != LocationPermissionState.granted) {
      state = state.copyWith(errorMessage: '位置情報の許可が必要です。');
      return false;
    }
    if (body.trim().isEmpty || body.trim().length > 30) {
      state = state.copyWith(errorMessage: 'ウィスパーは30文字以内で入力してください。');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final whispers = await _repository.createWhisper(
      body: body.trim(),
      exactLat: exactLat,
      exactLng: exactLng,
      gridMeters: gridMeters,
    );
    state = state.copyWith(
      isSubmitting: false,
      whispers: whispers,
      clearError: true,
    );
    return true;
  }

  Future<void> report({
    required String whisperId,
    required ReportReason reason,
  }) async {
    final whispers = await _repository.reportWhisper(
      whisperId: whisperId,
      reason: reason,
    );
    state = state.copyWith(whispers: whispers, clearError: true);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}
