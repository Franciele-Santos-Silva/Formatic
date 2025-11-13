class Flashcard {
  final int id;
  final String userId;
  final String question;
  final String answer;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Flashcard({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    required this.createdAt,
    this.updatedAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    userId: json['user_id'],
    question: json['question'],
    answer: json['answer'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'question': question,
    'answer': answer,
    'created_at': createdAt.toIso8601String(),
  };
}
