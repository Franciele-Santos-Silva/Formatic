class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        username: json['username'],
        avatarUrl: json['avatar_url'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
