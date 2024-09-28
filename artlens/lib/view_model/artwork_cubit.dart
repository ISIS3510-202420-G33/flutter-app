import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../entities/museum.dart';
import '../entities/comment.dart';
import '../model/artwork_service.dart';
import '../model/artist_service.dart';
import '../model/museum_service.dart';


abstract class ArtworkState {}

class ArtworkInitial extends ArtworkState {}

class ArtworkLoading extends ArtworkState {}

class ArtworkLoaded extends ArtworkState {
  final Artwork? artwork;
  final Artist? artist;
  final Museum? museum;
  final List<Comment>? comments;
  final List<Artwork>? artworksByArtistId;

  ArtworkLoaded({this.artwork, this.artist, this.museum, this.comments, this.artworksByArtistId});
}

class ArtworkError extends ArtworkState {
  final String message;

  ArtworkError(this.message);
}

class ArtworkCubit extends Cubit<ArtworkState> {
  final ArtworkService artworkService;
  final ArtistService artistService;
  final MuseumService museumService;

  ArtworkCubit(this.artworkService, this.artistService, this.museumService) : super(ArtworkInitial());

  Future<void> fetchArtworkById(int id) async {
    try {
      emit(ArtworkLoading());
      final artwork = await artworkService.fetchArtworkById(id);
      emit(ArtworkLoaded(artwork: artwork));
    } catch (e) {
      emit(ArtworkError('Error fetching artwork: ${e.toString()}'));
    }
  }

  Future<void> fetchArtworkAndRelatedEntities(int id) async {
    try {
      emit(ArtworkLoading());
      final artwork = await artworkService.fetchArtworkById(id);
      final artist = await artistService.fetchArtistById(artwork.artist);
      final museum = await museumService.fetchMuseumById(artwork.museum);
      final comments = await artworkService.fetchCommentsByArtworkId(id);
      emit(ArtworkLoaded(artwork: artwork, artist: artist, museum: museum, comments: comments));
    } catch (e) {
      emit(ArtworkError('Error fetching artwork and related entities: ${e.toString()}'));
    }
  }

  Future<void> fetchArtworksByArtistId(int id) async {
    try {
      emit(ArtworkLoading());
      final artworksByArtistId = await artworkService.fetchArtworksByArtistId(id);
      emit(ArtworkLoaded(artworksByArtistId: artworksByArtistId));
    } catch (e) {
      emit(ArtworkError('Error fetching artworks by artist id: ${e.toString()}'));
    }
  }
}