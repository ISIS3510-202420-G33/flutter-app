class Comment {
  final String content;
  final String date;
  final int artwork;
  final int user;

  Comment({
    required this.content,
    required this.date,
    required this.artwork,
    required this.user,
  });

  // Método para deserializar un JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      content: json["fields"]['content'],
      date: json["fields"]['date'],
      artwork: json["fields"]['artwork'],
      user: json["fields"]['user'],
    );
  }
}
