import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_preferences.dart';
import '../../auth/application/auth_controller.dart';
import '../data/mock_notification_service.dart';

final notificationServiceProvider = Provider<MockNotificationService>((ref) {
  return MockNotificationService();
});

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
      return NotificationsController(
        preferences: ref.watch(localPreferencesProvider),
        service: ref.watch(notificationServiceProvider),
      );
    });

class NotificationsState {
  const NotificationsState({
    this.isLoading = false,
    this.enabled = true,
    this.deviceToken,
  });

  final bool isLoading;
  final bool enabled;
  final String? deviceToken;

  NotificationsState copyWith({
    bool? isLoading,
    bool? enabled,
    String? deviceToken,
    bool clearDeviceToken = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      enabled: enabled ?? this.enabled,
      deviceToken: clearDeviceToken ? null : deviceToken ?? this.deviceToken,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController({
    required LocalPreferences preferences,
    required MockNotificationService service,
  }) : _preferences = preferences,
       _service = service,
       super(const NotificationsState()) {
    bootstrap();
  }

  final LocalPreferences _preferences;
  final MockNotificationService _service;
  StreamSubscription<String>? _openSubscription;

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true);
    final enabled = await _preferences.loadNotificationEnabled();

    String? token;
    if (enabled) {
      token = await _service.registerDeviceToken();
    }

    _openSubscription?.cancel();
    _openSubscription = _service.openEventStream().listen((_) {});

    state = state.copyWith(
      isLoading: false,
      enabled: enabled,
      deviceToken: token,
      clearDeviceToken: token == null,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true, enabled: enabled);
    await _preferences.setNotificationEnabled(enabled);

    if (enabled) {
      final token = await _service.registerDeviceToken();
      state = state.copyWith(isLoading: false, deviceToken: token);
      return;
    }

    await _service.unregisterDeviceToken();
    state = state.copyWith(isLoading: false, clearDeviceToken: true);
  }

  @override
  void dispose() {
    _openSubscription?.cancel();
    super.dispose();
  }
}
