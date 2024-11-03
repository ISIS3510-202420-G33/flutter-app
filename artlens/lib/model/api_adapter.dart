import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../entities/artist.dart';
import '../entities/artwork.dart';

class ApiAdapter {
  final String baseUrl = 'http://192.168.20.181:8000';
  final Box<Artwork> _spotlightArtworksBox = Hive.box('spotlightArtworks');
  final Box _metadataBox = Hive.box('metadata');

  static final ApiAdapter _instance = ApiAdapter._privateConstructor();

  ApiAdapter._privateConstructor();

  static ApiAdapter get instance => _instance;

  // Método para realizar solicitudes POST desde un Isolate
  static Future<http.Response> _postIsolate(Map<String, dynamic> params) {
    final String endpoint = params['endpoint'];
    final Map<String, dynamic> body = params['body'];
    final String baseUrl = 'http://192.168.20.181:8000'; 

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
