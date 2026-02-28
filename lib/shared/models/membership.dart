enum SpaceRole { guest, owner, primaryOwner }

enum MembershipStatus { none, pending, active, suspended, kicked, banned, left }

extension SpaceRoleCodec on SpaceRole {
  String get wireValue {
    switch (this) {
      case SpaceRole.guest:
        return 'guest';
      case SpaceRole.owner:
        return 'owner';
      case SpaceRole.primaryOwner:
        return 'primary_owner';
    }
  }
}

SpaceRole roleFromWire(String value) {
  switch (value) {
    case 'primary_owner':
      return SpaceRole.primaryOwner;
    case 'owner':
      return SpaceRole.owner;
    case 'guest':
    default:
      return SpaceRole.guest;
  }
}

extension MembershipStatusCodec on MembershipStatus {
  String get wireValue {
    switch (this) {
      case MembershipStatus.none:
        return 'none';
      case MembershipStatus.pending:
        return 'pending';
      case MembershipStatus.active:
        return 'active';
      case MembershipStatus.suspended:
        return 'suspended';
      case MembershipStatus.kicked:
        return 'kicked';
      case MembershipStatus.banned:
        return 'banned';
      case MembershipStatus.left:
        return 'left';
    }
  }

  String get label {
    switch (this) {
      case MembershipStatus.none:
        return '未参加';
      case MembershipStatus.pending:
        return '承認待ち';
      case MembershipStatus.active:
        return '参加中';
      case MembershipStatus.suspended:
        return '停止中';
      case MembershipStatus.kicked:
        return 'キック済み';
      case MembershipStatus.banned:
        return 'BAN';
      case MembershipStatus.left:
        return '退出';
    }
  }
}

MembershipStatus membershipStatusFromWire(String value) {
  switch (value) {
    case 'pending':
      return MembershipStatus.pending;
    case 'active':
      return MembershipStatus.active;
    case 'suspended':
      return MembershipStatus.suspended;
    case 'kicked':
      return MembershipStatus.kicked;
    case 'banned':
      return MembershipStatus.banned;
    case 'left':
      return MembershipStatus.left;
    case 'none':
    default:
      return MembershipStatus.none;
  }
}

class SpaceMembership {
  const SpaceMembership({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.role,
    required this.status,
    this.suspendedUntil,
  });

  final String id;
  final String spaceId;
  final String userId;
  final SpaceRole role;
  final MembershipStatus status;
  final DateTime? suspendedUntil;

  bool get canUseWhisper {
    return status == MembershipStatus.active;
  }

  bool get isBlockedFromSpace {
    return status == MembershipStatus.kicked ||
        status == MembershipStatus.banned ||
        status == MembershipStatus.left;
  }

  SpaceMembership copyWith({
    String? id,
    String? spaceId,
    String? userId,
    SpaceRole? role,
    MembershipStatus? status,
    DateTime? suspendedUntil,
    bool clearSuspendedUntil = false,
  }) {
    return SpaceMembership(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      suspendedUntil: clearSuspendedUntil
          ? null
          : suspendedUntil ?? this.suspendedUntil,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'userId': userId,
      'role': role.wireValue,
      'status': status.wireValue,
      'suspendedUntil': suspendedUntil?.toIso8601String(),
    };
  }

  factory SpaceMembership.fromJson(Map<String, dynamic> json) {
    return SpaceMembership(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      userId: json['userId'] as String,
      role: roleFromWire(json['role'] as String),
      status: membershipStatusFromWire(json['status'] as String),
      suspendedUntil: json['suspendedUntil'] == null
          ? null
          : DateTime.parse(json['suspendedUntil'] as String),
    );
  }
}
