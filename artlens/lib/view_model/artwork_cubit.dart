// /lib/cubits/artwork_cubit.dart

import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../entities/comment.dart';
import '../model/artwork_service.dart';

// Definimos los estados que el Cubit puede tener
abstract class ArtworkState {}

class ArtworkInitial extends ArtworkState {}

class ArtworkLoading extends ArtworkState {}

class ArtworkLoaded extends ArtworkState {
  final Artwork artwork;
  final List<Comment> comments;

  ArtworkLoaded(this.artwork, this.comments);
}

class ArtworkError extends ArtworkState {
  final String message;

  ArtworkError(this.message);
}

// Definimos el Cubit que maneja el estado relacionado con Artwork
class ArtworkCubit extends Cubit<ArtworkState> {
  final ArtworkService artworkService;

  ArtworkCubit(this.artworkService) : super(ArtworkInitial());

  // Método para obtener una obra de arte por su ID y los comentarios
  Future<void> fetchArtworkAndComments(int id) async {
    try {
      emit(ArtworkLoading()); // Emitimos el estado de carga
      final artwork = await artworkService.fetchArtworkById(id);
      final comments = await artworkService.fetchCommentsByArtworkId(id);;
      emit(ArtworkLoaded(artwork, comments)); // Emitimos el estado cargado con los datos
    } catch (e) {
      emit(ArtworkError('Error fetching artwork and comments: ${e.toString()}')); // Emitimos estado de error
    }
  }
}