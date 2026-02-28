import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../application/posts_controller.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postFuture = ref
        .read(postsControllerProvider.notifier)
        .findById(postId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('記事詳細'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: postFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data;
          if (post == null) {
            return const Center(child: Text('記事が見つかりません。'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(DateFormat('yyyy/MM/dd HH:mm').format(post.publishedAt)),
              const SizedBox(height: 18),
              Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          );
        },
      ),
    );
  }
}
