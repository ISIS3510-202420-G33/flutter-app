class Comment {
  final int id;
  final String content;
  final DateTime date;
  final int artwork;
  final int user;

  Comment({
    required this.id,
    required this.content,
    required this.date,
    required this.artwork,
    required this.user,
  });

  // Método para deserializar un JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      date: json['date'],
      artwork: json['artwork'],
      user: json['user'],
    );
  }
}
