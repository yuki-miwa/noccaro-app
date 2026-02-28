import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/post.dart';
import '../data/mock_posts_repository.dart';

final postsRepositoryProvider = Provider<MockPostsRepository>((ref) {
  return MockPostsRepository();
});

final postsControllerProvider =
    StateNotifierProvider<PostsController, PostsState>((ref) {
      return PostsController(ref.watch(postsRepositoryProvider));
    });

class PostsState {
  const PostsState({
    this.isLoading = false,
    this.posts = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<SpacePost> posts;
  final String? errorMessage;

  PostsState copyWith({
    bool? isLoading,
    List<SpacePost>? posts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PostsState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PostsController extends StateNotifier<PostsState> {
  PostsController(this._repository) : super(const PostsState());

  final MockPostsRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _repository.fetchPosts();
      state = state.copyWith(isLoading: false, posts: posts, clearError: true);
    } on Object {
      state = state.copyWith(isLoading: false, errorMessage: '投稿の読み込みに失敗しました。');
    }
  }

  Future<void> toggleReaction(String postId) async {
    final posts = await _repository.toggleReaction(postId);
    state = state.copyWith(posts: posts, clearError: true);
  }

  Future<SpacePost?> findById(String postId) {
    return _repository.findById(postId);
  }
}
