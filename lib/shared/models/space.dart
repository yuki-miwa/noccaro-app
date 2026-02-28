enum JoinPolicy { autoApprove, approvalRequired }

extension JoinPolicyCodec on JoinPolicy {
  String get wireValue {
    switch (this) {
      case JoinPolicy.autoApprove:
        return 'auto_approve';
      case JoinPolicy.approvalRequired:
        return 'approval_required';
    }
  }

  String get label {
    switch (this) {
      case JoinPolicy.autoApprove:
        return '自動承認';
      case JoinPolicy.approvalRequired:
        return '承認制';
    }
  }
}

JoinPolicy joinPolicyFromWire(String value) {
  switch (value) {
    case 'auto_approve':
      return JoinPolicy.autoApprove;
    case 'approval_required':
    default:
      return JoinPolicy.approvalRequired;
  }
}

class Space {
  const Space({
    required this.id,
    required this.code,
    required this.name,
    required this.joinPolicy,
  });

  final String id;
  final String code;
  final String name;
  final JoinPolicy joinPolicy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'joinPolicy': joinPolicy.wireValue,
    };
  }

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      joinPolicy: joinPolicyFromWire(json['joinPolicy'] as String),
    );
  }
}
