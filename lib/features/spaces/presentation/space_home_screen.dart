import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/models/membership.dart';
import '../../posts/presentation/post_feed_screen.dart';
import '../../whispers/presentation/whisper_map_screen.dart';
import '../application/space_controller.dart';

class SpaceHomeScreen extends ConsumerStatefulWidget {
  const SpaceHomeScreen({super.key});

  static const routePath = '/home';

  @override
  ConsumerState<SpaceHomeScreen> createState() => _SpaceHomeScreenState();
}

class _SpaceHomeScreenState extends ConsumerState<SpaceHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(spaceState.currentSpace!.name),
            Text(
              'ステータス: ${membership.status.label}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        toolbarHeight: 68,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoute.settings.path),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          PostFeedBody(
            onPostTap: (post) {
              context.push('${AppRoute.posts.path}/${post.id}');
            },
          ),
          WhisperMapBody(membership: membership),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'オーナー記事',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'マップ',
          ),
        ],
      ),
    );
  }
}
