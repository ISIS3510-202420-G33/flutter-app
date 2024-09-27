import 'dart:convert';
import '../entities/artwork.dart';
import '../model/api_adapter.dart'; // Asegúrate de importar tu ApiAdapter
import '../entities/comment.dart'; // Asegúrate de importar el modelo Comment

class ArtworkService {
  // Singleton
  static final ArtworkService _instance = ArtworkService._internal();
  factory ArtworkService() {
    return _instance;
  }
  ArtworkService._internal();

  // Instancia del ApiAdapter
  final ApiAdapter apiAdapter = ApiAdapter();

  // Método para obtener una obra de arte por su ID
  Future<Artwork> fetchArtworkById(int id) async {
    final response = await apiAdapter.get('/artwork/$id');
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return Artwork.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Failed to load artwork: ${response.reasonPhrase}');
    }
  }

  // Método para obtener los comentarios de una obra de arte por su ID
  Future<List<Comment>> fetchCommentsByArtworkId(int id) async {
    final response = await apiAdapter.get('/artwork/comments/$id');
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }
}
