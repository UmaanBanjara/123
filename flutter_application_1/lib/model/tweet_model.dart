class Tweet {
  final int id;
  final int userId;
  final String content;
  final String? mediaUrl;    // nullable
  final DateTime createdAt;
  final String? location;    // nullable

  Tweet({
    required this.id,
    required this.userId,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    this.location,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(json['created_at']),
      location: json['location'],
    );
  }
}
