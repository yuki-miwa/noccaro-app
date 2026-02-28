import 'dart:async';

import '../../../core/mock/mock_seed.dart';
import '../../../shared/models/post.dart';

class MockPostsRepository {
  final List<SpacePost> _posts = MockSeed.defaultPosts();

  Future<List<SpacePost>> fetchPosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final sorted = [..._posts]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return sorted;
  }

  Future<SpacePost?> findById(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _posts.where((item) => item.id == postId).firstOrNull;
  }

  Future<List<SpacePost>> toggleReaction(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final index = _posts.indexWhere((item) => item.id == postId);
    if (index == -1) {
      return fetchPosts();
    }

    final current = _posts[index];
    final nextReacted = !current.reactedByMe;
    final nextCount = nextReacted
        ? current.reactionCount + 1
        : (current.reactionCount - 1).clamp(0, 1 << 30);

    _posts[index] = current.copyWith(
      reactedByMe: nextReacted,
      reactionCount: nextCount,
    );

    return fetchPosts();
  }
}
