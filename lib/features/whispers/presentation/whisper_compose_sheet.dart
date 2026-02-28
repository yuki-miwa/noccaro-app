import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/membership.dart';
import '../application/whispers_controller.dart';

class WhisperComposeSheet extends ConsumerStatefulWidget {
  const WhisperComposeSheet({super.key, required this.membership});

  final SpaceMembership? membership;

  @override
  ConsumerState<WhisperComposeSheet> createState() =>
      _WhisperComposeSheetState();
}

class _WhisperComposeSheetState extends ConsumerState<WhisperComposeSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    final baseLat = 35.680959;
    final baseLng = 139.767306;
    final lat = baseLat + (Random().nextDouble() - 0.5) * 0.003;
    final lng = baseLng + (Random().nextDouble() - 0.5) * 0.003;

    final success = await ref
        .read(whispersControllerProvider.notifier)
        .create(
          body: text,
          membership: widget.membership,
          exactLat: lat,
          exactLng: lng,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whispersControllerProvider);
    final remaining = 30 - _controller.text.characters.length;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ウィスパー投稿',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLength: 30,
            maxLines: 2,
            decoration: const InputDecoration(hintText: '30文字以内で入力してください'),
            onChanged: (_) => setState(() {}),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('残り $remaining 文字'),
          ),
          if (state.errorMessage != null)
            Text(
              state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: state.isSubmitting ? null : _submit,
            child: state.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('投稿する'),
          ),
        ],
      ),
    );
  }
}
