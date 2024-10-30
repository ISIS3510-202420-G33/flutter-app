import 'package:bloc/bloc.dart';
import '../entities/comment.dart';
import '../model/comments_service.dart';

abstract class CommentsState {}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState{
  final List<Comment> comments;
  final String username;

  CommentsLoaded(this.comments, this.username);
}

class CommentsError extends CommentsState {
  final String message;

  CommentsError(this.message);
}

class CommentsCubit extends Cubit<CommentsState> {
  final CommentsService commentService;

  CommentsCubit(this.commentService) : super(CommentsInitial());

  Future<void> fetchCommentsByArtworkId(int artworkId, int userId) async {
    try {
      emit(CommentsLoading());
      final comments = await commentService.fetchCommentsByArtworkId(artworkId);
      final username = await commentService.getUsernameById(userId);
      emit(CommentsLoaded(comments, username));
    } catch (e) {
      emit(CommentsError('Error fetching comments: ${e.toString()}'));
    }
  }

  Future<void> postComment(String content, String date, int artworkId, int userId) async {
    try {
      emit(CommentsLoading());
      await commentService.postComment(content, date, artworkId, userId);
      final comments = await commentService.fetchCommentsByArtworkId(artworkId);
      final username = await commentService.getUsernameById(userId);
      emit(CommentsLoaded(comments, username));
    } catch (e) {
      emit(CommentsError('Error posting comment: ${e.toString()}'));
    }
  }
}
