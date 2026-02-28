import 'package:flutter_test/flutter_test.dart';
import 'package:noccaro_app/features/whispers/application/whispers_controller.dart';
import 'package:noccaro_app/features/whispers/data/mock_whispers_repository.dart';
import 'package:noccaro_app/shared/models/membership.dart';

void main() {
  group('Whispers blocked behavior', () {
    test('suspended users cannot load or create whispers', () async {
      final controller = WhispersController(MockWhispersRepository());

      final suspendedMembership = SpaceMembership(
        id: 'membership-1',
        spaceId: 'space-1',
        userId: 'user-1',
        role: SpaceRole.guest,
        status: MembershipStatus.suspended,
      );

      await controller.load(membership: suspendedMembership);
      expect(controller.state.whispers, isEmpty);

      await controller.requestPermission();
      final success = await controller.create(
        body: 'hello',
        membership: suspendedMembership,
        exactLat: 35.68,
        exactLng: 139.76,
      );
      expect(success, isFalse);
    });

    test('active users can create whispers after permission granted', () async {
      final controller = WhispersController(MockWhispersRepository());

      final activeMembership = SpaceMembership(
        id: 'membership-2',
        spaceId: 'space-1',
        userId: 'user-1',
        role: SpaceRole.guest,
        status: MembershipStatus.active,
      );

      await controller.requestPermission();
      final success = await controller.create(
        body: 'active user whisper',
        membership: activeMembership,
        exactLat: 35.68,
        exactLng: 139.76,
      );

      expect(success, isTrue);
      expect(controller.state.whispers, isNotEmpty);
    });
  });
}
