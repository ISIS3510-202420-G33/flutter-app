import 'dart:convert';
import '../entities/artist.dart';
import '../model/api_adapter.dart';

class ArtistService {
  static final ArtistService _instance = ArtistService._internal();

  factory ArtistService() {
    return _instance;
  }

  ArtistService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<Artist> fetchArtistById(int id) async {
    final response = await apiAdapter.get('/artists/$id');
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return Artist.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Failed to load artist: ${response.reasonPhrase}');
    }
  }

  Future<List<Artist>> fetchAllArtists() async {
    final response = await apiAdapter.get('/artists');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artist.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artists: ${response.reasonPhrase}');
    }
  }

}
