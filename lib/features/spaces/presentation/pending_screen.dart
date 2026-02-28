import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/models/membership.dart';
import '../application/space_controller.dart';

class SpacePendingScreen extends ConsumerWidget {
  const SpacePendingScreen({super.key});

  static const routePath = '/space-pending';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceState = ref.watch(spaceControllerProvider);
    final membership = spaceState.membership;

    return Scaffold(
      appBar: AppBar(title: const Text('承認待ち')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  '参加申請を送信しました',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${spaceState.currentSpace?.name ?? 'スペース'} のオーナー承認を待っています。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: membership?.status == MembershipStatus.pending
                      ? () async {
                          await ref
                              .read(spaceControllerProvider.notifier)
                              .approvePendingForDemo();
                          if (context.mounted) {
                            context.go(AppRoute.home.path);
                          }
                        }
                      : null,
                  child: const Text('承認されたことにする（モック）'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.go(AppRoute.join.path),
                  child: const Text('コード入力に戻る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
