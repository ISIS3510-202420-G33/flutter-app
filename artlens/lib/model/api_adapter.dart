import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../entities/artist.dart';
import '../entities/artwork.dart';
import '../entities/comment.dart';
import '../entities/museum.dart';

class ApiAdapter {

  final String baseUrl = 'http://192.168.5.105:8000';

  //Cache
  final CacheManager _cacheManager = DefaultCacheManager();

  //Local Storage
  final Box<Artwork> _spotlightArtworksBox = Hive.box('spotlightArtworks');
  final Box _metadataBox = Hive.box('metadata');

  static final ApiAdapter _instance = ApiAdapter._privateConstructor();

  ApiAdapter._privateConstructor();

  static ApiAdapter get instance => _instance;

  // Método para realizar solicitudes POST desde un Isolate
  static Future<http.Response> _postIsolate(Map<String, dynamic> params) {
    final String endpoint = params['endpoint'];
    final Map<String, dynamic> body = params['body'];
    final String baseUrl = params['baseUrl'];

    final url = Uri.parse('$baseUrl$endpoint');

    // Realiza la solicitud POST
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // Método para solicitudes POST que llama al método del Isolate
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    return compute(_postIsolate, {
      'baseUrl': baseUrl,
      'endpoint': endpoint,
      'body': body,
    });
  }

  // Método para solicitudes GET
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // Método para solicitudes DELETE
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url);
      return response;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  /// Artwork

  Future<Artwork> fetchArtworkById(int id) async {
    // Cache key to store artwork data JC
    final cacheKey = 'artwork_$id';
    final cachedFile = await _cacheManager.getFileFromCache(cacheKey);


    if (cachedFile != null) {
      // If the file exists in the cache, use it
      final cachedData = await cachedFile.file.readAsString();
      final decodedData = jsonDecode(cachedData);

      if (decodedData is List && decodedData.isNotEmpty) {
        final artworkData = Map<String, dynamic>.from(decodedData[0]);
        return Artwork.fromJson(artworkData);
      } else {
        throw Exception('Invalid cached data format for artwork');
      }
    } else {
      // If not in cache, fetch from the network
      final response = await get('/artworks/$id');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final artwork = Artwork.fromJson(Map<String, dynamic>.from(jsonResponse[0]));

        // Cache the response for future use
        await _cacheManager.putFile(
          cacheKey,
          response.bodyBytes,
          fileExtension: 'json',
        );

        return artwork;
      } else {
        throw Exception('Failed to load artwork: ${response.reasonPhrase}');
      }
    }
  }

  Future<List<Comment>> fetchCommentsByArtworkId(int id) async {
    final response = await get('/artworks/comments/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchArtworksByArtistId(int id) async {
    final response = await get('/artworks/artist/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchArtworksByMuseumId(int museumId) async {
    final response = await get('/artworks/museum/$museumId');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artworks for museum: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchAllArtworks() async {
    final response = await get('/artworks');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artworks: ${response.reasonPhrase}');
    }
  }

  /// Artist

  Future<Artist> fetchArtistById(int id) async {
    // Cache key to store artist data JC
    final cacheKey = 'artist_$id';
    final cachedFile = await _cacheManager.getFileFromCache(cacheKey);

    if (cachedFile != null) {
      // If the file exists in the cache, use it
      final cachedData = await cachedFile.file.readAsString();
      final decodedData = jsonDecode(cachedData);

      if (decodedData is List && decodedData.isNotEmpty) {
        final artistData = Map<String, dynamic>.from(decodedData[0]);
        return Artist.fromJson(artistData);
      } else {
        throw Exception('Invalid cached data format for artist');
      }
    } else {
      // If not in cache, fetch from the network
      final response = await get('/artists/$id');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final artist = Artist.fromJson(Map<String, dynamic>.from(jsonResponse[0]));

        // Cache the response for future use
        await _cacheManager.putFile(
          cacheKey,
          response.bodyBytes,
          fileExtension: 'json',
        );

        return artist;
      } else {
        throw Exception('Failed to load artist: ${response.reasonPhrase}');
      }
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

  ///Museum

  Future<Museum> fetchMuseumById(int id) async {
    // Cache key to store museum data JC
    final cacheKey = 'museum_$id';
    final cachedFile = await _cacheManager.getFileFromCache(cacheKey);

    if (cachedFile != null) {
      // If the file exists in the cache, use it
      final cachedData = await cachedFile.file.readAsString();
      final decodedData = jsonDecode(cachedData);

      if (decodedData is List && decodedData.isNotEmpty) {
        final museumData = Map<String, dynamic>.from(decodedData[0]);
        return Museum.fromJson(museumData);
      } else {
        throw Exception('Invalid cached data format for museum');
      }
    } else {
      // If not in cache, fetch from the network
      final response = await get('/museums/$id');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final museum = Museum.fromJson(Map<String, dynamic>.from(jsonResponse[0]));

        // Cache the response for future use
        await _cacheManager.putFile(
          cacheKey,
          response.bodyBytes,
          fileExtension: 'json',
        );

        return museum;
      } else {
        throw Exception('Failed to load museum: ${response.reasonPhrase}');
      }
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

  /// Analytic Engine

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
    if (_shouldUseLocalData()) {
      return _spotlightArtworksBox.values.toList();
    }

    final response = await get('/analytic_engine/spotlights/');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Artwork> artworks = jsonData.map((data) => Artwork.fromJson(data)).toList();
      await _saveSpotlightArtworksToLocalStorage(artworks);
      return artworks;
    } else {
      throw Exception('Failed to load spotlight artworks: ${response.reasonPhrase}');
    }
  }

  bool _shouldUseLocalData() {
    final lastRefreshDateStr = _metadataBox.get('lastRefreshDate');
    if (lastRefreshDateStr != null) {
      final lastRefreshDate = DateFormat('yyyy-MM-dd').parse(lastRefreshDateStr);
      final currentDate = DateTime.now();
      return currentDate.difference(lastRefreshDate).inDays < 5;
    }
    return false;
  }

  Future<void> _saveSpotlightArtworksToLocalStorage(List<Artwork> artworks) async {
    await _spotlightArtworksBox.clear();
    for (Artwork artwork in artworks) {
      await _spotlightArtworksBox.add(artwork);
    }
    final currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _metadataBox.put('lastRefreshDate', currentDateStr);
  }
}
