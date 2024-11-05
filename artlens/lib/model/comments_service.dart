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
    return await apiAdapter.fetchCommentsByArtworkId(artworkId);
  }

  Future<Comment> postComment(String content, String date, int artworkId, int userId) async {
    return await apiAdapter.postComment(content, date, artworkId, userId);
  }

  Future<String> getUsernameById(int userId) async {
    return await apiAdapter.getUsernameById(userId);
  }

}
