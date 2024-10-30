import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../entities/artwork.dart';
import '../model/api_adapter.dart';

class AnalyticEngineService {
  static final AnalyticEngineService _instance = AnalyticEngineService._internal();
  final ApiAdapter apiAdapter = ApiAdapter.instance;
  final Box<Artwork> _spotlightArtworksBox = Hive.box('spotlightArtworks');
  final Box _metadataBox = Hive.box('metadata');

  factory AnalyticEngineService() {
    return _instance;
  }

  AnalyticEngineService._internal();

  Future<List<Artwork>> fetchRecommendationsByUserId(int id) async {
    final response = await apiAdapter.get('/analytic_engine/recommend/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load recommendations: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchSpotlightArtworks() async {
    // Check if the data is locally available and fresh
    if (_shouldUseLocalData()) {
      return _spotlightArtworksBox.values.toList();
    }

    // Fetch from the backend if local data is outdated
    final response = await apiAdapter.get('/analytic_engine/spotlights/');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Artwork> artworks = jsonData.map((data) => Artwork.fromJson(data)).toList();

      // Cache the fetched data
      await _saveSpotlightArtworksToLocalStorage(artworks);

      return artworks;
    } else {
      throw Exception('Failed to load spotlight artworks: ${response.reasonPhrase}');
    }
  }

  bool _shouldUseLocalData() {
    // Retrieve the last refresh date from the metadata box
    final lastRefreshDateStr = _metadataBox.get('lastRefreshDate');
    if (lastRefreshDateStr != null) {
      final lastRefreshDate = DateFormat('yyyy-MM-dd').parse(lastRefreshDateStr);
      final currentDate = DateTime.now();
      // Use local data if it's within the 5-day refresh window
      return currentDate.difference(lastRefreshDate).inDays < 5;
    }
    // If no refresh date exists, fetch from network
    return false;
  }

  // Save artworks to local storage and update the refresh date
  Future<void> _saveSpotlightArtworksToLocalStorage(List<Artwork> artworks) async {
    // Clear old data in the box
    await _spotlightArtworksBox.clear();

    // Save new data to the box
    for (Artwork artwork in artworks) {
      await _spotlightArtworksBox.add(artwork);
    }

    // Update the last refresh date in the metadata box
    final currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _metadataBox.put('lastRefreshDate', currentDateStr);
  }
}
