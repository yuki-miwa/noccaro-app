import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../application/posts_controller.dart';

class PostFeedScreen extends ConsumerStatefulWidget {
  const PostFeedScreen({super.key});

  static const routePath = '/posts';

  @override
  ConsumerState<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends ConsumerState<PostFeedScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(postsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('オーナー記事'),
        leading: BackButton(onPressed: () => context.go(AppRoute.home.path)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(postsControllerProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (postsState.isLoading)
              const LinearProgressIndicator(minHeight: 3),
            if (postsState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  postsState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (!postsState.isLoading && postsState.posts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: Text('投稿はまだありません。')),
              ),
            ...postsState.posts.map((post) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    onTap: () =>
                        context.go('${AppRoute.posts.path}/${post.id}'),
                    title: Text(post.title),
                    subtitle: Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(post.publishedAt),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('${post.reactionCount}'),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(postsControllerProvider.notifier)
                                .toggleReaction(post.id);
                          },
                          icon: Icon(
                            post.reactedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: post.reactedByMe
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
