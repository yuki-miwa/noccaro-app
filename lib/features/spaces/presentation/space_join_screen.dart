import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/models/membership.dart';
import '../../auth/application/auth_controller.dart';
import '../application/space_controller.dart';

class SpaceJoinScreen extends ConsumerStatefulWidget {
  const SpaceJoinScreen({super.key});

  static const routePath = '/join-space';

  @override
  ConsumerState<SpaceJoinScreen> createState() => _SpaceJoinScreenState();
}

class _SpaceJoinScreenState extends ConsumerState<SpaceJoinScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text;
    if (code.trim().isEmpty) {
      return;
    }

    final success = await ref
        .read(spaceControllerProvider.notifier)
        .joinByCode(code);
    if (!success || !mounted) {
      return;
    }

    final membership = ref.read(spaceControllerProvider).membership;
    if (membership == null) {
      return;
    }

    if (membership.status == MembershipStatus.pending) {
      context.go(AppRoute.pending.path);
    } else {
      context.go(AppRoute.home.path);
    }
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.go(AppRoute.login.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spaceState = ref.watch(spaceControllerProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('スペース参加'),
        actions: [TextButton(onPressed: _logout, child: const Text('ログアウト'))],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${user?.displayName ?? 'ユーザー'} さん',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'スペースコードを入力して参加申請してください。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'スペースコード',
                    hintText: '例: NOC2026',
                  ),
                ),
                if (spaceState.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    spaceState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: spaceState.isLoading ? null : _join,
                  child: spaceState.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('参加する'),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('ローカルモック用コード'),
                        SizedBox(height: 8),
                        Text('NOC2026 : 承認制（pending状態になる）'),
                        Text('AUTO2026 : 自動承認（すぐ利用可能）'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
