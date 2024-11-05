// artwork_cubit.dart
import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../entities/museum.dart';
import '../model/artwork_service.dart';
import '../model/artist_service.dart';
import '../model/museum_service.dart';
import '../model/firestore_service.dart';

abstract class ArtworkState {}

class ArtworkInitial extends ArtworkState {}

class ArtworkLoading extends ArtworkState {}

class ArtworkLoaded extends ArtworkState {
  final Artwork? artwork;
  final Artist? artist;
  final Museum? museum;
  final List<Artwork>? artworksByArtistId;

  ArtworkLoaded({
    this.artwork,
    this.artist,
    this.museum,
    this.artworksByArtistId,
  });
}

class ArtworkError extends ArtworkState {
  final String message;

  ArtworkError(this.message);
}

class ArtworkCubit extends Cubit<ArtworkState> {
  final ArtworkService artworkService;
  final ArtistService artistService;
  final MuseumService museumService;
  final FirestoreService firestoreService;

  // Cache for artworks by artist
  Map<int, List<Artwork>> cachedArtworksByArtist = {};

  ArtworkCubit(
      this.artworkService,
      this.artistService,
      this.museumService,
      this.firestoreService,
      ) : super(ArtworkInitial());

  Future<void> fetchArtworkById(int id) async {
    print("Starting fetch for artwork ID: $id");
    emit(ArtworkLoading());
    try {
      final artwork = await artworkService.fetchArtworkById(id);
      print("Fetched artwork: ${artwork.name}");
      emit(ArtworkLoaded(artwork: artwork));
    } catch (e) {
      print("Error fetching artwork: ${e.toString()}");
      emit(ArtworkError('Error fetching artwork: ${e.toString()}'));
    }
  }

  Future<void> fetchArtworksByArtistId(int artistId) async {
    print("Fetching artworks for artist ID: $artistId");
    if (cachedArtworksByArtist.containsKey(artistId)) {
      print("Data already in cache for artist ID: $artistId");
      emit(ArtworkLoaded(artworksByArtistId: cachedArtworksByArtist[artistId]));
      return;
    }

    emit(ArtworkLoading());
    try {
      final artworks = await artworkService.fetchArtworksByArtistId(artistId);
      print("Fetched ${artworks.length} artworks for artist ID: $artistId");
      cachedArtworksByArtist[artistId] = artworks;
      emit(ArtworkLoaded(artworksByArtistId: artworks));
    } catch (e) {
      print("Error fetching artworks by artist id: ${e.toString()}");
      emit(ArtworkError('Error fetching artworks by artist id: ${e.toString()}'));
    }
  }

  void clearCache() {
    print("Clearing cache for artworks by artist");
    cachedArtworksByArtist.clear();
  }

  Future<void> fetchArtworkAndRelatedEntities(int artworkId) async {
    emit(ArtworkLoading());
    try {
      final artwork = await artworkService.fetchArtworkById(artworkId);
      final artist = await artistService.fetchArtistById(artwork.artist);
      final museum = await museumService.fetchMuseumById(artwork.museum);
      emit(ArtworkLoaded(
        artwork: artwork,
        artist: artist,
        museum: museum,
      ));
    } catch (e) {
      emit(ArtworkError('Error fetching artwork and related entities: ${e.toString()}'));
    }
  }
}
