class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'title': title, 'description': description};
  }
}
