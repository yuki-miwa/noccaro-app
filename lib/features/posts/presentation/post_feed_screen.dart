import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../shared/models/post.dart';
import '../application/posts_controller.dart';

class PostFeedScreen extends StatelessWidget {
  const PostFeedScreen({super.key});

  static const routePath = '/posts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オーナー記事'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoute.home.path);
          },
        ),
      ),
      body: const PostFeedBody(),
    );
  }
}

class PostFeedBody extends ConsumerStatefulWidget {
  const PostFeedBody({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.onPostTap,
  });

  final EdgeInsets padding;
  final ValueChanged<SpacePost>? onPostTap;

  @override
  ConsumerState<PostFeedBody> createState() => _PostFeedBodyState();
}

class _PostFeedBodyState extends ConsumerState<PostFeedBody> {
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

    return RefreshIndicator(
      onRefresh: () => ref.read(postsControllerProvider.notifier).load(),
      child: ListView(
        padding: widget.padding,
        children: [
          if (postsState.isLoading) const LinearProgressIndicator(minHeight: 3),
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
                  onTap: () {
                    if (widget.onPostTap != null) {
                      widget.onPostTap!(post);
                      return;
                    }
                    context.push('${AppRoute.posts.path}/${post.id}');
                  },
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
    );
  }
}
