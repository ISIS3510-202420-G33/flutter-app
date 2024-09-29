import 'artwork.dart';  // Importing Artwork since likedArtworks is a list of Artwork objects

class User {
  final int id;
  final String name;
  final String userName;
  final String email;
  final List<Artwork> likedArtworks; // List of liked artworks

  User({
    required this.id,
    required this.name,
    required this.userName,
    required this.email,
    required this.likedArtworks,
  });

  // Deserialize from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    var likedArtworksFromJson = json['fields']['likedArtwoks'] ?? []; // Si es null, usa lista vacía
    List<Artwork> likedArtworksList = (likedArtworksFromJson as List).map((artworkJson) {
      return Artwork.fromJson(artworkJson);
    }).toList();

    return User(
      id: json['pk'],
      name: json['fields']['name'],
      userName: json['fields']['userName'],
      email: json['fields']['email'],
      likedArtworks: likedArtworksList,
    );

  }
}
