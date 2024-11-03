import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../entities/artist.dart';
import '../entities/artwork.dart';
import '../entities/museum.dart';

class ApiAdapter {
  final String baseUrl = 'http://192.168.5.105:8000';
  final Box<Artwork> _spotlightArtworksBox = Hive.box('spotlightArtworks');
  final Box _metadataBox = Hive.box('metadata');

  static final ApiAdapter _instance = ApiAdapter._privateConstructor();

  ApiAdapter._privateConstructor();

  static ApiAdapter get instance => _instance;

  // Method for POST requests
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // Method for GET requests
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // Method for DELETE requests
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url);
      return response;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  Future<List<Artist>> fetchAllArtists() async {
    final response = await get('/artists');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artist.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artists: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchRecommendationsByUserId(int id) async {
    final response = await get('/analytic_engine/recommend/$id');
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
    final response = await get('/analytic_engine/spotlights/');
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

  Future<List<Museum>> fetchAllMuseums() async {
    final response = await get('/museums');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Museum.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load museums: ${response.reasonPhrase}');
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
