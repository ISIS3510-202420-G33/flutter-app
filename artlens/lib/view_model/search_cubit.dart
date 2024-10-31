import 'package:artlens/model/artist_service.dart';
import 'package:artlens/model/artwork_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../entities/museum.dart';
import '../model/museum_service.dart';

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
  final ArtworkService artworkService;
  final MuseumService museumService;
  final ArtistService artistService;
  List<Artwork> _allArtworks = [];
  List<Artist> _allArtists = [];
  List<Museum> _allMuseums = [];

  SearchCubit(this.artworkService, this.museumService, this.artistService) : super(SearchInitial());

  Future<void> fetchAllData() async {
    emit(SearchLoading());
    try {
      final artworks = await artworkService.fetchAllArtworks();
      final artists = await artistService.fetchAllArtists();
      final museums = await museumService.fetchAllMuseums();

      final results = await compute(_processFetchedData, {
        'artworks': artworks,
        'artists': artists,
        'museums': museums,
      });

      _allArtworks = (results['artworks'] as List).cast<Artwork>();
      _allArtists = (results['artists'] as List).cast<Artist>();
      _allMuseums = (results['museums'] as List).cast<Museum>();

      emit(SearchLoaded(artworks: _allArtworks, artists: _allArtists, museums: _allMuseums));

    } catch (e) {
      emit(SearchError('Error fetching data: ${e.toString()}'));
    }
  }

  static Map<String, List<dynamic>> _processFetchedData(Map<String, List<dynamic>> data) {

    List<Artwork> artworks = (data['artworks'] as List<Artwork>)
        .where((artwork) => artwork.name.length > 5)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    List<Artist> artists = (data['artists'] as List<Artist>)
        .where((artist) => artist.name.length > 5)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    List<Museum> museums = (data['museums'] as List<Museum>)
        .where((museum) => museum.name.length > 5)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return {
      'artworks': artworks,
      'artists': artists,
      'museums': museums,
    };
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
