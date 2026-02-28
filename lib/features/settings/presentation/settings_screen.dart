import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/models/membership.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../spaces/application/space_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final spaceState = ref.watch(spaceControllerProvider);
    final notificationState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('アカウント', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('表示名: ${authState.user?.displayName ?? '-'}'),
                  Text('メール: ${authState.user?.email ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: notificationState.enabled,
              title: const Text('プッシュ通知を受け取る'),
              subtitle: Text(
                notificationState.deviceToken == null
                    ? 'デバイストークン未登録'
                    : 'token: ${notificationState.deviceToken}',
              ),
              onChanged: notificationState.isLoading
                  ? null
                  : (value) {
                      ref
                          .read(notificationsControllerProvider.notifier)
                          .setEnabled(value);
                    },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'メンバー状態デバッグ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MembershipStatus.values
                        .where((status) => status != MembershipStatus.none)
                        .map(
                          (status) => OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(spaceControllerProvider.notifier)
                                  .setMembershipStatusForDemo(status);
                              if (status == MembershipStatus.pending) {
                                context.go(AppRoute.pending.path);
                              }
                              if (status == MembershipStatus.kicked ||
                                  status == MembershipStatus.banned ||
                                  status == MembershipStatus.left) {
                                context.go(AppRoute.join.path);
                              }
                            },
                            child: Text(status.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 8),
                  Text('現在: ${spaceState.membership?.status.label ?? '未参加'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoute.login.path);
              }
            },
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }
}
