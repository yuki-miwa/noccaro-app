enum WhisperStatus { active, hiddenByReport, removedByOwner, expired }

extension WhisperStatusCodec on WhisperStatus {
  String get wireValue {
    switch (this) {
      case WhisperStatus.active:
        return 'active';
      case WhisperStatus.hiddenByReport:
        return 'hidden_by_report';
      case WhisperStatus.removedByOwner:
        return 'removed_by_owner';
      case WhisperStatus.expired:
        return 'expired';
    }
  }
}

WhisperStatus whisperStatusFromWire(String value) {
  switch (value) {
    case 'hidden_by_report':
      return WhisperStatus.hiddenByReport;
    case 'removed_by_owner':
      return WhisperStatus.removedByOwner;
    case 'expired':
      return WhisperStatus.expired;
    case 'active':
    default:
      return WhisperStatus.active;
  }
}

class Whisper {
  const Whisper({
    required this.id,
    required this.body,
    required this.displayLat,
    required this.displayLng,
    required this.expiresAt,
    required this.status,
    required this.reportCount,
  });

  final String id;
  final String body;
  final double displayLat;
  final double displayLng;
  final DateTime expiresAt;
  final WhisperStatus status;
  final int reportCount;

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  Whisper copyWith({
    String? id,
    String? body,
    double? displayLat,
    double? displayLng,
    DateTime? expiresAt,
    WhisperStatus? status,
    int? reportCount,
  }) {
    return Whisper(
      id: id ?? this.id,
      body: body ?? this.body,
      displayLat: displayLat ?? this.displayLat,
      displayLng: displayLng ?? this.displayLng,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'displayLat': displayLat,
      'displayLng': displayLng,
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.wireValue,
      'reportCount': reportCount,
    };
  }

  factory Whisper.fromJson(Map<String, dynamic> json) {
    return Whisper(
      id: json['id'] as String,
      body: json['body'] as String,
      displayLat: (json['displayLat'] as num).toDouble(),
      displayLng: (json['displayLng'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: whisperStatusFromWire(json['status'] as String),
      reportCount: json['reportCount'] as int,
    );
  }
}
