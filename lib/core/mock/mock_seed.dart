import '../../shared/models/post.dart';
import '../../shared/models/space.dart';
import '../../shared/models/whisper.dart';

class MockSeed {
  const MockSeed._();

  static const defaultSpaces = [
    Space(
      id: 'space-approval-1',
      code: 'NOC2026',
      name: 'Noccaro コミュニティ (承認制)',
      joinPolicy: JoinPolicy.approvalRequired,
    ),
    Space(
      id: 'space-auto-1',
      code: 'AUTO2026',
      name: 'Noccaro テストルーム (自動承認)',
      joinPolicy: JoinPolicy.autoApprove,
    ),
  ];

  static List<SpacePost> defaultPosts() {
    final now = DateTime.now();
    return [
      SpacePost(
        id: 'post-1',
        title: 'コミュニティ運用ポリシー',
        body: 'このスペースは閉鎖型コミュニティです。投稿は節度を守って利用してください。',
        publishedAt: now.subtract(const Duration(hours: 9)),
        reactionCount: 9,
        reactedByMe: false,
      ),
      SpacePost(
        id: 'post-2',
        title: '今週の案内',
        body: '明日のメンテナンス時間は 01:00-02:00 です。',
        publishedAt: now.subtract(const Duration(hours: 3)),
        reactionCount: 4,
        reactedByMe: true,
      ),
      SpacePost(
        id: 'post-3',
        title: '匿名ウィスパーの使い方',
        body: 'ウィスパーは3時間で表示終了し、返信・リアクションはできません。',
        publishedAt: now.subtract(const Duration(minutes: 50)),
        reactionCount: 2,
        reactedByMe: false,
      ),
    ];
  }

  static List<Whisper> defaultWhispers() {
    final now = DateTime.now();
    return [
      Whisper(
        id: 'whisper-1',
        body: '駅前が少し混んでます',
        displayLat: 35.680959,
        displayLng: 139.767306,
        expiresAt: now.add(const Duration(hours: 2, minutes: 30)),
        status: WhisperStatus.active,
        reportCount: 0,
      ),
      Whisper(
        id: 'whisper-2',
        body: 'この辺り静かで作業しやすい',
        displayLat: 35.681812,
        displayLng: 139.769883,
        expiresAt: now.add(const Duration(hours: 1, minutes: 20)),
        status: WhisperStatus.active,
        reportCount: 1,
      ),
    ];
  }
}
