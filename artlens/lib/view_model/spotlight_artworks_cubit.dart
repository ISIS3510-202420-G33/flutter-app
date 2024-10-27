import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../model/analytic_engine_service.dart';

abstract class SpotlightArtworksState {}

class SpotlightArtworksInitial extends SpotlightArtworksState {}

class SpotlightArtworksLoading extends SpotlightArtworksState {}

class SpotlightArtworksLoaded extends SpotlightArtworksState {
  final List<Artwork> spotlightArtworks;

  SpotlightArtworksLoaded(this.spotlightArtworks);
}

class SpotlightArtworksError extends SpotlightArtworksState {
  final String message;

  SpotlightArtworksError(this.message);
}

class SpotlightArtworksCubit extends Cubit<SpotlightArtworksState> {
  final AnalyticEngineService analyticEngineService;

  SpotlightArtworksCubit(this.analyticEngineService) : super(SpotlightArtworksInitial());

  Future<void> fetchSpotlightArtworks() async {
    try {
      emit(SpotlightArtworksLoading());
      final spotlightArtworks = await analyticEngineService.fetchSpotlightArtworks();
      emit(SpotlightArtworksLoaded(spotlightArtworks));
    } catch (e) {
      emit(SpotlightArtworksError('Error fetching spotlight artworks: ${e.toString()}'));
    }
  }
}
