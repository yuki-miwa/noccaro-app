import 'dart:async';

class MockNotificationService {
  Future<String> registerDeviceToken() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return 'mock-device-token-001';
  }

  Future<void> unregisterDeviceToken() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  Stream<String> openEventStream() {
    return const Stream<String>.empty();
  }
}
