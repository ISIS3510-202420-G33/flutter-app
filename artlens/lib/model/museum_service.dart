import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../entities/museum.dart';
import '../model/api_adapter.dart';

class MuseumService {
  static final MuseumService _instance = MuseumService._internal();

  factory MuseumService() {
    return _instance;
  }

  MuseumService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;
  final CacheManager _cacheManager = DefaultCacheManager();

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
      final response = await apiAdapter.get('/museums/$id');
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
    final response = await apiAdapter.get('/museums');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Museum.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load museums: ${response.reasonPhrase}');
    }
  }
}
