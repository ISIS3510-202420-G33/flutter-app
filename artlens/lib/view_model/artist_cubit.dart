import 'package:bloc/bloc.dart';
import '../entities/artist.dart';
import '../model/artist_service.dart';

abstract class ArtistState {}

class ArtistInitial extends ArtistState {}

class ArtistLoading extends ArtistState {}

class ArtistLoaded extends ArtistState {
  final Artist artist;

  ArtistLoaded(this.artist);
}

class ArtistsLoaded extends ArtistState {
  final List<Artist> artists;

  ArtistsLoaded(this.artists);
}

class Error extends ArtistState {
  final String message;

  Error(this.message);
}

class ArtistCubit extends Cubit<ArtistState> {
  final ArtistService artistService;

  ArtistCubit(this.artistService) : super(ArtistInitial());

  Future<void> fetchArtistById(int id) async {
    try {
      emit(ArtistLoading());
      final artist = await artistService.fetchArtistById(id);
      emit(ArtistLoaded(artist));
    } catch (e) {
      emit(Error('Error fetching artist: ${e.toString()}'));
    }
  }

  Future<void> fetchArtists() async {
    try {
      emit(ArtistLoading());
      final museums = await artistService.fetchAllArtists();
      emit(ArtistsLoaded(museums));
    } catch (e) {
      emit(Error('Error fetching artists: ${e.toString()}'));
    }
  }
}