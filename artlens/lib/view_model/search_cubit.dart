import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../entities/museum.dart';
import '../model/search_service.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Artwork> artworks;
  final List<Artist> artists;
  final List<Museum> museums;

  SearchLoaded({required this.artworks, required this.artists, required this.museums});
}

class SearchFiltered extends SearchState {
  final List<Artwork> filteredArtworks;
  final List<Artist> filteredArtists;
  final List<Museum> filteredMuseums;

  SearchFiltered({required this.filteredArtworks, required this.filteredArtists, required this.filteredMuseums});
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final SearchService searchService;
  List<Artwork> _allArtworks = [];
  List<Artist> _allArtists = [];
  List<Museum> _allMuseums = [];

  SearchCubit(this.searchService) : super(SearchInitial());

  Future<void> fetchAllData() async {
    emit(SearchLoading());
    try {
      _allArtworks = await searchService.fetchAllArtworks();
      _allArtists = await searchService.fetchAllArtists();
      _allMuseums = await searchService.fetchAllMuseums();
      emit(SearchLoaded(artworks: _allArtworks, artists: _allArtists, museums: _allMuseums));
    } catch (e) {
      emit(SearchError('Error fetching data: ${e.toString()}'));
    }
  }

  void filterData(String query) {
    if (query.isEmpty) {
      emit(SearchLoaded(artworks: _allArtworks, artists: _allArtists, museums: _allMuseums));
      return;
    }

    final filteredArtworks = _allArtworks.where((artwork) => artwork.name.toLowerCase().contains(query.toLowerCase())).toList();
    final filteredArtists = _allArtists.where((artist) => artist.name.toLowerCase().contains(query.toLowerCase())).toList();
    final filteredMuseums = _allMuseums.where((museum) => museum.name.toLowerCase().contains(query.toLowerCase())).toList();

    emit(SearchFiltered(filteredArtworks: filteredArtworks, filteredArtists: filteredArtists, filteredMuseums: filteredMuseums));
  }
}
