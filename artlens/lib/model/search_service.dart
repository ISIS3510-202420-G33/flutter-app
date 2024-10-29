import 'dart:convert';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../entities/museum.dart';
import '../model/api_adapter.dart';

class SearchService {
  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<List<Artwork>> fetchAllArtworks() async {
    final response = await apiAdapter.get('/artworks');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artworks: ${response.reasonPhrase}');
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

  Future<List<Museum>> fetchAllMuseums() async {
    final response = await apiAdapter.get('/museums');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Museum.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load museums: ${response.reasonPhrase}');
    }
  }
}
