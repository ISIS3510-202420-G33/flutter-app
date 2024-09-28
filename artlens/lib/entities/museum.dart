class Museum {
  final int id;
  final String name;
  final String latitude;
  final String longitude;
  final String category;
  final String city;
  final String country;
  final String description;
  final String image;

  Museum({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.city,
    required this.country,
    required this.description,
    required this.image,
  });

  // Método para deserializar un JSON
  factory Museum.fromJson(Map<String, dynamic> json) {
    return Museum(
      id: json['pk'],
      name: json["fields"]['name'],
      latitude: json["fields"]['latitude'],
      longitude: json["fields"]['longitude'],
      category: json["fields"]['category'],
      city: json["fields"]['city'],
      country: json["fields"]['country'],
      description: json["fields"]['description'],
      image: json["fields"]['image'],
    );
  }
}
