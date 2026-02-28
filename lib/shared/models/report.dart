enum ReportReason { spam, harassment, privacyRisk, inappropriate, other }

extension ReportReasonCodec on ReportReason {
  String get wireValue {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.privacyRisk:
        return 'privacy_risk';
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ReportReason.spam:
        return 'スパム';
      case ReportReason.harassment:
        return '嫌がらせ';
      case ReportReason.privacyRisk:
        return 'プライバシー侵害';
      case ReportReason.inappropriate:
        return '不適切';
      case ReportReason.other:
        return 'その他';
    }
  }
}
