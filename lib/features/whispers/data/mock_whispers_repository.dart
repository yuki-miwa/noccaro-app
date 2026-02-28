import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../core/mock/mock_seed.dart';
import '../../../shared/models/report.dart';
import '../../../shared/models/whisper.dart';

class MockWhispersRepository {
  MockWhispersRepository();

  final List<Whisper> _whispers = MockSeed.defaultWhispers();

  Future<List<Whisper>> fetchWhispers() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final now = DateTime.now();
    for (var i = 0; i < _whispers.length; i += 1) {
      final whisper = _whispers[i];
      if (whisper.expiresAt.isBefore(now) &&
          whisper.status == WhisperStatus.active) {
        _whispers[i] = whisper.copyWith(status: WhisperStatus.expired);
      }
    }

    return _whispers
        .where((item) => item.status == WhisperStatus.active)
        .toList(growable: false)
      ..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
  }

  Future<List<Whisper>> createWhisper({
    required String body,
    required double exactLat,
    required double exactLng,
    required int gridMeters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final rounded = _roundAndJitter(
      lat: exactLat,
      lng: exactLng,
      gridMeters: gridMeters,
    );

    final whisper = Whisper(
      id: const Uuid().v4(),
      body: body,
      displayLat: rounded.$1,
      displayLng: rounded.$2,
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      status: WhisperStatus.active,
      reportCount: 0,
    );

    _whispers.insert(0, whisper);
    return fetchWhispers();
  }

  Future<List<Whisper>> reportWhisper({
    required String whisperId,
    required ReportReason reason,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final index = _whispers.indexWhere((item) => item.id == whisperId);
    if (index == -1) {
      return fetchWhispers();
    }

    final current = _whispers[index];
    final nextCount = current.reportCount + 1;
    final nextStatus = nextCount >= 5
        ? WhisperStatus.hiddenByReport
        : current.status;

    _whispers[index] = current.copyWith(
      reportCount: nextCount,
      status: nextStatus,
    );
    return fetchWhispers();
  }

  (double, double) _roundAndJitter({
    required double lat,
    required double lng,
    required int gridMeters,
  }) {
    const metersPerLatDegree = 111000.0;
    final metersPerLngDegree = metersPerLatDegree * cos(lat * pi / 180);

    final latStep = gridMeters / metersPerLatDegree;
    final lngStep = gridMeters / metersPerLngDegree;

    final baseLat = (lat / latStep).floor() * latStep;
    final baseLng = (lng / lngStep).floor() * lngStep;

    final jitterLat = (Random().nextDouble() - 0.5) * latStep * 0.6;
    final jitterLng = (Random().nextDouble() - 0.5) * lngStep * 0.6;

    return (baseLat + jitterLat, baseLng + jitterLng);
  }
}
