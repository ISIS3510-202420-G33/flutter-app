import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../entities/artist.dart';
import '../model/api_adapter.dart';

class ArtistService {
  static final ArtistService _instance = ArtistService._internal();

  factory ArtistService() {
    return _instance;
  }

  ArtistService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;
  final CacheManager _cacheManager = DefaultCacheManager();

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
      final response = await apiAdapter.get('/artists/$id');
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
    final response = await apiAdapter.get('/artists');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artist.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load artists: ${response.reasonPhrase}');
    }
  }
}
