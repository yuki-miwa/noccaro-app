import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app/router.dart';
import '../../../core/env/app_env.dart';
import '../../../shared/models/membership.dart';
import '../../../shared/models/report.dart';
import '../../../shared/widgets/state_message.dart';
import '../../spaces/application/space_controller.dart';
import '../application/whispers_controller.dart';
import 'whisper_compose_sheet.dart';

class WhisperMapScreen extends ConsumerStatefulWidget {
  const WhisperMapScreen({super.key});

  static const routePath = '/whispers';

  @override
  ConsumerState<WhisperMapScreen> createState() => _WhisperMapScreenState();
}

class _WhisperMapScreenState extends ConsumerState<WhisperMapScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    final membership = ref.read(spaceControllerProvider).membership;
    await ref
        .read(whispersControllerProvider.notifier)
        .load(membership: membership);
  }

  Future<void> _openCompose(SpaceMembership? membership) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WhisperComposeSheet(membership: membership),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final whisperState = ref.watch(whispersControllerProvider);
    final membership = ref.watch(spaceControllerProvider).membership;

    final canUseWhisper = membership?.status == MembershipStatus.active;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ウィスパーマップ'),
        leading: BackButton(onPressed: () => context.go(AppRoute.home.path)),
      ),
      floatingActionButton: canUseWhisper
          ? FloatingActionButton.extended(
              onPressed: () => _openCompose(membership),
              icon: const Icon(Icons.edit),
              label: const Text('投稿'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!canUseWhisper)
            const StateMessage(
              title: '現在は利用できません',
              message: 'ステータスが active のときのみウィスパー閲覧・投稿が可能です。',
              icon: Icons.lock_outline,
            )
          else if (whisperState.permission != LocationPermissionState.granted)
            StateMessage(
              title: '位置情報の許可が必要です',
              message: 'ウィスパー投稿時に現在地を送信し、サーバーで丸め処理を行います。',
              icon: Icons.location_disabled_outlined,
              actionLabel: '許可する（モック）',
              onAction: () {
                ref
                    .read(whispersControllerProvider.notifier)
                    .requestPermission();
              },
            )
          else ...[
            if (AppEnv.enableNativeMapWidget)
              SizedBox(
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(35.680959, 139.767306),
                      zoom: 14,
                    ),
                    markers: whisperState.whispers
                        .map(
                          (whisper) => Marker(
                            markerId: MarkerId(whisper.id),
                            position: LatLng(
                              whisper.displayLat,
                              whisper.displayLng,
                            ),
                          ),
                        )
                        .toSet(),
                  ),
                ),
              )
            else
              const StateMessage(
                title: 'マップ表示 (モックモード)',
                message: 'APIキー未設定のため、現在は座標一覧で確認できます。',
                icon: Icons.map_outlined,
              ),
            const SizedBox(height: 12),
            if (whisperState.isLoading)
              const LinearProgressIndicator(minHeight: 3),
            if (whisperState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  whisperState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (!whisperState.isLoading && whisperState.whispers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Center(child: Text('表示できるウィスパーがありません。')),
              ),
            ...whisperState.whispers.map((whisper) {
              final expiresIn = whisper.expiresAt.difference(DateTime.now());
              final remainText =
                  '${expiresIn.inHours}h ${(expiresIn.inMinutes % 60).toString().padLeft(2, '0')}m';

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Card(
                  child: ListTile(
                    title: Text(whisper.body),
                    subtitle: Text(
                      '(${whisper.displayLat.toStringAsFixed(5)}, ${whisper.displayLng.toStringAsFixed(5)})  残り $remainText',
                    ),
                    trailing: PopupMenuButton<ReportReason>(
                      onSelected: (reason) {
                        ref
                            .read(whispersControllerProvider.notifier)
                            .report(whisperId: whisper.id, reason: reason);
                      },
                      itemBuilder: (context) {
                        return ReportReason.values
                            .map(
                              (reason) => PopupMenuItem(
                                value: reason,
                                child: Text('通報: ${reason.label}'),
                              ),
                            )
                            .toList(growable: false);
                      },
                      icon: const Icon(Icons.report_outlined),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
