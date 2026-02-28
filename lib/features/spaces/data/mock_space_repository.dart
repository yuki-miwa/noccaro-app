import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/mock/mock_seed.dart';
import '../../../core/storage/local_preferences.dart';
import '../../../shared/models/membership.dart';
import '../../../shared/models/space.dart';

class SpaceJoinResult {
  const SpaceJoinResult({required this.space, required this.membership});

  final Space space;
  final SpaceMembership membership;
}

class MockSpaceRepository {
  MockSpaceRepository({required LocalPreferences localPreferences})
    : _localPreferences = localPreferences;

  final LocalPreferences _localPreferences;

  Future<Space?> loadCurrentSpace() {
    return _localPreferences.loadSpace();
  }

  Future<SpaceMembership?> loadMembership() {
    return _localPreferences.loadMembership();
  }

  Future<SpaceJoinResult> joinByCode({
    required String spaceCode,
    required String userId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));

    final normalizedCode = spaceCode.trim().toUpperCase();
    final matchedSpace = MockSeed.defaultSpaces
        .where((space) => space.code.toUpperCase() == normalizedCode)
        .firstOrNull;

    if (matchedSpace == null) {
      throw StateError('スペースコードが見つかりません。');
    }

    final membershipStatus = matchedSpace.joinPolicy == JoinPolicy.autoApprove
        ? MembershipStatus.active
        : MembershipStatus.pending;

    final membership = SpaceMembership(
      id: const Uuid().v4(),
      spaceId: matchedSpace.id,
      userId: userId,
      role: SpaceRole.guest,
      status: membershipStatus,
    );

    await _localPreferences.saveSpace(matchedSpace);
    await _localPreferences.saveMembership(membership);

    return SpaceJoinResult(space: matchedSpace, membership: membership);
  }

  Future<SpaceMembership> updateMembershipStatus({
    required SpaceMembership current,
    required MembershipStatus status,
    DateTime? suspendedUntil,
  }) async {
    final updated = current.copyWith(
      status: status,
      suspendedUntil: suspendedUntil,
      clearSuspendedUntil: status != MembershipStatus.suspended,
    );
    await _localPreferences.saveMembership(updated);
    return updated;
  }

  Future<void> clear() {
    return _localPreferences.clearSessionState();
  }
}
