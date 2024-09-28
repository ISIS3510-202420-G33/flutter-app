import 'dart:convert';
import '../entities/artwork.dart';
import '../model/api_adapter.dart';
import '../entities/comment.dart';

class ArtworkService {
  static final ArtworkService _instance = ArtworkService._internal();

  factory ArtworkService() {
    return _instance;
  }

  ArtworkService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<Artwork> fetchArtworkById(int id) async {
    final response = await apiAdapter.get('/artwork/$id');
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return Artwork.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Failed to load artwork: ${response.reasonPhrase}');
    }
  }

  Future<List<Comment>> fetchCommentsByArtworkId(int id) async {
    final response = await apiAdapter.get('/artwork/comments/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchArtworksByArtistId(int id) async {
    final response = await apiAdapter.get('/artwork/artist/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

}
