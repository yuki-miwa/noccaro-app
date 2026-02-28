import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noccaro_app/core/storage/local_preferences.dart';
import 'package:noccaro_app/features/spaces/application/space_controller.dart';
import 'package:noccaro_app/features/spaces/data/mock_space_repository.dart';
import 'package:noccaro_app/features/spaces/presentation/pending_screen.dart';
import 'package:noccaro_app/shared/models/membership.dart';
import 'package:noccaro_app/shared/models/space.dart';

void main() {
  testWidgets('shows pending membership state message', (tester) async {
    const seedState = SpaceState(
      bootstrapped: true,
      currentSpace: Space(
        id: 'space-1',
        code: 'NOC2026',
        name: 'Noccaro コミュニティ',
        joinPolicy: JoinPolicy.approvalRequired,
      ),
      membership: SpaceMembership(
        id: 'membership-1',
        spaceId: 'space-1',
        userId: 'user-1',
        role: SpaceRole.guest,
        status: MembershipStatus.pending,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          spaceControllerProvider.overrideWith(
            (ref) => _TestSpaceController(ref: ref, seed: seedState),
          ),
        ],
        child: const MaterialApp(home: SpacePendingScreen()),
      ),
    );

    expect(find.text('参加申請を送信しました'), findsOneWidget);
    expect(find.textContaining('オーナー承認を待っています。'), findsOneWidget);
    expect(find.text('承認されたことにする（モック）'), findsOneWidget);
  });
}

class _TestSpaceController extends SpaceController {
  _TestSpaceController({required super.ref, required SpaceState seed})
    : super(
        repository: MockSpaceRepository(localPreferences: LocalPreferences()),
      ) {
    state = seed;
  }

  @override
  Future<void> bootstrap() async {}
}
