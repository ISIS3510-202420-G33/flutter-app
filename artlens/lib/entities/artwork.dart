import 'package:hive/hive.dart';

part 'artwork.g.dart';  // Required for Hive to generate serialization code

@HiveType(typeId: 1)  // Assign a unique typeId for the adapter (ensure it's unique)
class Artwork extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String technique;

  @HiveField(4)
  final String dimensions;

  @HiveField(5)
  final String interpretation;

  @HiveField(6)
  final String advancedInfo;

  @HiveField(7)
  final String image;

  @HiveField(8)
  final bool isSpotlight;

  @HiveField(9)
  final int museum;

  @HiveField(10)
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
    required this.isSpotlight,
    required this.museum,
    required this.artist,
  });

  // Method to deserialize JSON to Artwork object
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
      isSpotlight: json["fields"]['isSpotlight'],
      museum: json["fields"]['museum'],
      artist: json["fields"]['artist'],
    );
  }

  // Method to serialize Artwork object to JSON
  Map<String, dynamic> toJson() {
    return {
      'pk': id,
      'fields': {
        'name': name,
        'date': date,
        'technique': technique,
        'dimensions': dimensions,
        'interpretation': interpretation,
        'advancedInfo': advancedInfo,
        'image': image,
        'isSpotlight': isSpotlight,
        'museum': museum,
        'artist': artist,
      },
    };
  }
}
