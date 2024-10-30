// museum_artwork_cubit.dart
import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../model/artwork_service.dart';

abstract class MuseumArtworkState {}

class MuseumArtworkInitial extends MuseumArtworkState {}

class MuseumArtworkLoading extends MuseumArtworkState {}

class MuseumArtworkLoaded extends MuseumArtworkState {
  final List<Artwork> artworksByMuseumId;

  MuseumArtworkLoaded(this.artworksByMuseumId);
}

class MuseumArtworkError extends MuseumArtworkState {
  final String message;

  MuseumArtworkError(this.message);
}

class MuseumArtworkCubit extends Cubit<MuseumArtworkState> {
  final ArtworkService artworkService;
  final Map<int, List<Artwork>> cachedArtworksByMuseum = {};

  MuseumArtworkCubit(this.artworkService) : super(MuseumArtworkInitial());

  void forceReloadArtworksForMuseum(int museumId) {
    if (cachedArtworksByMuseum.containsKey(museumId)) {
      print("Forcing reload of artworks for museum ID: $museumId");
      emit(MuseumArtworkLoaded(cachedArtworksByMuseum[museumId]!));
    }
  }

  Future<void> fetchArtworksByMuseumId(int museumId) async {
    print("Fetching artworks for museum ID: $museumId");

    // Check cache first
    if (cachedArtworksByMuseum.containsKey(museumId)) {
      print("Data already in cache for museum ID: $museumId");
      emit(MuseumArtworkLoaded(cachedArtworksByMuseum[museumId]!));
      return;
    }

    emit(MuseumArtworkLoading());
    try {
      final artworks = await artworkService.fetchArtworksByMuseumId(museumId);
      print("Fetched ${artworks.length} artworks for museum ID: $museumId");
      cachedArtworksByMuseum[museumId] = artworks;
      emit(MuseumArtworkLoaded(artworks));
    } catch (e) {
      print("Error fetching artworks by museum id: ${e.toString()}");
      emit(MuseumArtworkError('Error fetching artworks by museum id: ${e.toString()}'));
    }
  }
}
