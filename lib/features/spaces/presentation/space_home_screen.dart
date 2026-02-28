import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/models/membership.dart';
import '../application/space_controller.dart';

class SpaceHomeScreen extends ConsumerWidget {
  const SpaceHomeScreen({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceState = ref.watch(spaceControllerProvider);
    final membership = spaceState.membership;

    if (spaceState.currentSpace == null || membership == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('スペースホーム')),
        body: const Center(child: Text('スペースに参加してください。')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(spaceState.currentSpace!.name),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoute.settings.path),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '現在の参加状態',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('ロール: ${membership.role.wireValue}'),
                  Text('ステータス: ${membership.status.label}'),
                  if (membership.status == MembershipStatus.suspended)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '停止中のためウィスパー閲覧・投稿は利用できません。',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.go(AppRoute.posts.path),
            icon: const Icon(Icons.article_outlined),
            label: const Text('オーナー記事を見る'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: membership.status == MembershipStatus.active
                ? () => context.go(AppRoute.whispers.path)
                : null,
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('ウィスパーを見る / 投稿する'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoute.settings.path),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('設定'),
          ),
        ],
      ),
    );
  }
}
