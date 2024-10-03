import 'package:bloc/bloc.dart';
import '../entities/comment.dart';
import '../model/comments_service.dart';

// Definir los estados
abstract class CommentsState {}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState{
  final List<Comment>? comments; // Si necesitas almacenar comentarios
  final String? username; // Agregar username aquí

  CommentsLoaded({this.comments, this.username});
}

class CommentPosted extends CommentsState {}

class CommentsError extends CommentsState {
  final String message;

  CommentsError(this.message);
}

// Definir el CommentsCubit
class CommentsCubit extends Cubit<CommentsState> {
  final CommentsService commentService;

  CommentsCubit(this.commentService) : super(CommentsInitial());

  // Método para obtener comentarios de una obra
  Future<List<Comment>> fetchCommentsByArtworkId(int artworkId) async {
    try {
      emit(CommentsLoading());
      final comments = await commentService.fetchCommentsByArtworkId(artworkId);
      emit(CommentsLoaded(comments: comments));
      return comments;
    } catch (e) {
      emit(CommentsError('Error fetching comments: ${e.toString()}'));
      return [];
    }
  }

  // Método para publicar un comentario
  Future<void> postComment(String content, String date, int artworkId, int userId) async {
    try {
      emit(CommentsLoading()); // Mostrar un indicador de carga mientras se envía el comentario
      await commentService.postComment(content, date, artworkId, userId);

      // Después de publicar el comentario, recargar los comentarios
      final comments = await commentService.fetchCommentsByArtworkId(artworkId);

      // Emitir los comentarios actualizados
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      emit(CommentsError('Error posting comment: ${e.toString()}'));
    }
  }

// Método para obtener el nombre de usuario a partir del ID
  Future<void> fetchUsername(int userId) async {
    emit(CommentsLoading());
    try {
      final username = await commentService.getUsernameById(userId);
      emit(CommentsLoaded(username: username));
    } catch (e) {
      emit(CommentsError('Error al cargar el nombre de usuario: $e'));
    }
  }
}
