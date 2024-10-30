import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../entities/artwork.dart';
import '../model/api_adapter.dart';
import '../entities/comment.dart';

class ArtworkService {
  static final ArtworkService _instance = ArtworkService._internal();
  final ApiAdapter apiAdapter = ApiAdapter.instance;
  final CacheManager _cacheManager = DefaultCacheManager();

  factory ArtworkService() {
    return _instance;
  }

  ArtworkService._internal();

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
      final response = await apiAdapter.get('/artworks/$id');
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
    final response = await apiAdapter.get('/artworks/comments/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchArtworksByArtistId(int id) async {
    final response = await apiAdapter.get('/artworks/artist/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchArtworksByMuseumId(int museumId) async {
    final response = await apiAdapter.get('/artworks/museum/$museumId');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artworks for museum: ${response.reasonPhrase}');
    }
  }

  Future<List<Artwork>> fetchAllArtworks() async {
    final response = await apiAdapter.get('/artworks');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artworks: ${response.reasonPhrase}');
    }
  }

}
