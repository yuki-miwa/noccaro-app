import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app/router.dart';
import '../../../shared/models/membership.dart';
import '../../../shared/models/report.dart';
import '../../../shared/models/whisper.dart';
import '../../../shared/widgets/state_message.dart';
import '../../spaces/application/space_controller.dart';
import '../application/whispers_controller.dart';
import 'whisper_compose_sheet.dart';

class WhisperMapScreen extends StatelessWidget {
  const WhisperMapScreen({super.key});

  static const routePath = '/whispers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ウィスパーマップ'),
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
      body: const WhisperMapBody(),
    );
  }
}

class WhisperMapBody extends ConsumerStatefulWidget {
  const WhisperMapBody({
    super.key,
    this.membership,
    this.showComposeButton = true,
  });

  final SpaceMembership? membership;
  final bool showComposeButton;

  @override
  ConsumerState<WhisperMapBody> createState() => _WhisperMapBodyState();
}

class _WhisperMapBodyState extends ConsumerState<WhisperMapBody> {
  String? _selectedWhisperId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    await ref
        .read(whispersControllerProvider.notifier)
        .load(membership: _resolvedMembership);
  }

  SpaceMembership? get _resolvedMembership {
    return widget.membership ?? ref.read(spaceControllerProvider).membership;
  }

  Future<void> _openCompose() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WhisperComposeSheet(membership: _resolvedMembership),
    );
    if (mounted) {
      await _load();
    }
  }

  String _remainingLabel(DateTime expiresAt) {
    final remain = expiresAt.difference(DateTime.now());
    final safeMinutes = remain.isNegative ? 0 : remain.inMinutes;
    final hours = safeMinutes ~/ 60;
    final minutes = safeMinutes % 60;
    return '残り ${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final whisperState = ref.watch(whispersControllerProvider);
    final membership =
        widget.membership ?? ref.watch(spaceControllerProvider).membership;

    final canUseWhisper = membership?.status == MembershipStatus.active;
    if (!canUseWhisper) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: StateMessage(
            title: '現在は利用できません',
            message: 'ステータスが active のときのみウィスパー閲覧・投稿が可能です。',
            icon: Icons.lock_outline,
          ),
        ),
      );
    }

    if (whisperState.permission != LocationPermissionState.granted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StateMessage(
            title: '位置情報の許可が必要です',
            message: 'ウィスパー投稿時に現在地を送信し、サーバーで丸め処理を行います。',
            icon: Icons.location_disabled_outlined,
            actionLabel: '許可する（モック）',
            onAction: () {
              ref.read(whispersControllerProvider.notifier).requestPermission();
            },
          ),
        ),
      );
    }

    final whispers = whisperState.whispers;
    final selected = whispers
        .where((item) => item.id == _selectedWhisperId)
        .firstOrNull;

    final initialTarget = whispers.isEmpty
        ? const LatLng(35.680959, 139.767306)
        : LatLng(whispers.first.displayLat, whispers.first.displayLng);

    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 14,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: whispers
                .map(
                  (whisper) => Marker(
                    markerId: MarkerId(whisper.id),
                    position: LatLng(whisper.displayLat, whisper.displayLng),
                    infoWindow: InfoWindow(
                      title: whisper.body,
                      snippet: _remainingLabel(whisper.expiresAt),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedWhisperId = whisper.id;
                      });
                    },
                  ),
                )
                .toSet(),
          ),
        ),
        if (whisperState.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 3),
          ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text('表示中: ${whispers.length}件'),
                  const Spacer(),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    tooltip: '再読み込み',
                  ),
                ],
              ),
            ),
          ),
        ),
        if (whisperState.errorMessage != null)
          Positioned(
            top: 78,
            left: 16,
            right: 16,
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  whisperState.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
        if (selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: widget.showComposeButton ? 96 : 16,
            child: _SelectedWhisperCard(
              whisper: selected,
              remainingLabel: _remainingLabel(selected.expiresAt),
              onClose: () {
                setState(() {
                  _selectedWhisperId = null;
                });
              },
              onReport: (reason) {
                ref
                    .read(whispersControllerProvider.notifier)
                    .report(whisperId: selected.id, reason: reason);
              },
            ),
          ),
        if (widget.showComposeButton)
          Positioned(
            right: 16,
            bottom: 20,
            child: FloatingActionButton.extended(
              onPressed: _openCompose,
              icon: const Icon(Icons.edit),
              label: const Text('投稿'),
            ),
          ),
      ],
    );
  }
}

class _SelectedWhisperCard extends StatelessWidget {
  const _SelectedWhisperCard({
    required this.whisper,
    required this.remainingLabel,
    required this.onClose,
    required this.onReport,
  });

  final Whisper whisper;
  final String remainingLabel;
  final VoidCallback onClose;
  final ValueChanged<ReportReason> onReport;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    whisper.body,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
            Text(
              '(${whisper.displayLat.toStringAsFixed(5)}, ${whisper.displayLng.toStringAsFixed(5)})',
            ),
            const SizedBox(height: 4),
            Text(remainingLabel),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<ReportReason>(
                onSelected: onReport,
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
          ],
        ),
      ),
    );
  }
}
