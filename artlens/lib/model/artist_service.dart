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

}
