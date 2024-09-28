import '../view_model/artwork_cubit.dart';
import '../view_model/artist_cubit.dart';
import '../view_model/museum_cubit.dart';

class AppFacade {
  final ArtworkCubit artworkCubit;
  final ArtistCubit artistCubit;
  final MuseumCubit museumCubit;

  AppFacade(this.artworkCubit, this.artistCubit, this.museumCubit);

  void fetchArtworkAndRelatedEntities(int id) {
    artworkCubit.fetchArtworkAndRelatedEntities(id);
  }

  void fetchArtworksByArtistId(int id) {
    artworkCubit.fetchArtworksByArtistId(id);
  }

  void fetchArtworkById(int id) {
    artworkCubit.fetchArtworkById(id);
  }

  void fetchArtistById(int id) {
    artistCubit.fetchArtistById(id);
  }

  void fetchMuseumById(int id) {
    museumCubit.fetchMuseumById(id);
  }
}