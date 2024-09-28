class Artist {
  final int id;
  final String name;
  final String biography;
  final String image;

  Artist({
    required this.id,
    required this.name,
    required this.biography,
    required this.image,
  });

  // Método para deserializar un JSON
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['pk'],
      name: json["fields"]['name'],
      biography: json["fields"]['biography'],
      image: json["fields"]['image'],
    );
  }
}
