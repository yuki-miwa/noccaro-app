class SpacePost {
  const SpacePost({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.reactionCount,
    required this.reactedByMe,
  });

  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final int reactionCount;
  final bool reactedByMe;

  SpacePost copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? publishedAt,
    int? reactionCount,
    bool? reactedByMe,
  }) {
    return SpacePost(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      publishedAt: publishedAt ?? this.publishedAt,
      reactionCount: reactionCount ?? this.reactionCount,
      reactedByMe: reactedByMe ?? this.reactedByMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'publishedAt': publishedAt.toIso8601String(),
      'reactionCount': reactionCount,
      'reactedByMe': reactedByMe,
    };
  }

  factory SpacePost.fromJson(Map<String, dynamic> json) {
    return SpacePost(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      reactionCount: json['reactionCount'] as int,
      reactedByMe: json['reactedByMe'] as bool,
    );
  }
}
