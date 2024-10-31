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

  Future<List<Comment>> fetchCommentsByArtworkId(int artworkId) async {
    final response = await apiAdapter.get('/artworks/comments/$artworkId');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<Comment> postComment(String content, String date, int artworkId, int userId) async {
    try {
      final response = await apiAdapter.post(
        '/comments/',
        {
          'content': content,
          'date': date,
          'artwork': artworkId,
          'user': userId,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final fields = jsonResponse[0];
          return Comment.fromJson(fields);
        } else {
          throw Exception("Unexpected JSON format: $jsonResponse");
        }
      } else {
        throw Exception('Failed to post comment: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception("Failed to post comment due to an unexpected error.");
    }
  }

  Future<String> getUsernameById(int userId) async {
    try {
      final response = await apiAdapter.get('/user');

      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
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
