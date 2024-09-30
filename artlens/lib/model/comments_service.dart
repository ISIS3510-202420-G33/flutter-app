import 'dart:convert';
import '../entities/comment.dart';
import '../model/api_adapter.dart';

class CommentsService {
  static final CommentsService _instance = CommentsService._internal();

  factory CommentsService() {
    return _instance;
  }

  CommentsService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  // Obtener comentarios por ID de obra de arte
  Future<List<Comment>> fetchCommentsByArtworkId(int artworkId) async {
    final response = await apiAdapter.get('/artworks/comments/$artworkId');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  // Publicar un nuevo comentario
  Future<Comment> postComment(String content, String date, int artworkId, int userId) async {
    final response = await apiAdapter.post(
      '/comments/', {
        'content': content,
        'date': date,
        'artwork': artworkId,
        'user': userId,
      });
    if (response.statusCode != 200) {
      throw Exception('Failed to post comment: ${response.reasonPhrase}');
    }
    else{
      final jsonResponse = jsonDecode(response.body);
      return Comment.fromJson(jsonResponse);
    }
  }
  // Método para obtener el nombre de usuario por su pk (ID)
  Future<String?> getUsernameById(int userId) async {
    try {
      // Realiza la petición al endpoint
      final response = await apiAdapter.get('/user');

      // Verifica si la petición fue exitosa
      if (response.statusCode == 200) {
        // Parsear el cuerpo de la respuesta a una lista de usuarios
        List<dynamic> users = jsonDecode(response.body);

        // Buscar el usuario específico según el `pk`
        final user = users.firstWhere((user) => user['pk'] == userId, orElse: () => null);

        // Si se encuentra el usuario, devolver su campo `name`
        return user != null ? user['fields']['name'] : null;
      } else {
        throw Exception('Error al obtener usuarios: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error al obtener el nombre de usuario: $e');
    }
  }

}
