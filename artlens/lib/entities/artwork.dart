class Artwork {
  final int id;
  final String name;
  final String date;
  final String technique;
  final String dimensions;
  final String interpretation;
  final String advancedInfo;
  final String image;
  final int museum;
  final int artist;

  Artwork({
    required this.id,
    required this.name,
    required this.date,
    required this.technique,
    required this.dimensions,
    required this.interpretation,
    required this.advancedInfo,
    required this.image,
    required this.museum,
    required this.artist,
  });

  // Método para deserializar un JSON
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['pk'],
      name: json["fields"]['name'],
      date: json["fields"]['date'],
      technique: json["fields"]['technique'],
      dimensions: json["fields"]['dimensions'],
      interpretation: json["fields"]['interpretation'],
      advancedInfo: json["fields"]['advancedInfo'],
      image: json["fields"]['image'],
      museum: json["fields"]['museum'],
      artist: json["fields"]['artist'],
    );
  }
}
