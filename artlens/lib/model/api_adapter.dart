import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/artist.dart';
import '../entities/artwork.dart';
import '../entities/comment.dart';
import '../entities/museum.dart';
import '../entities/user.dart';

class ApiAdapter {

  final String baseUrl = 'http://34.170.38.233:8000';

  //Cache
  final CacheManager _cacheManager = DefaultCacheManager();
  bool useCacheNext = false;

  //Local Storage
  final Box<Artwork> _favoritesBox = Hive.box<Artwork>('favoritesArtworks');
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

    if (cachedFile != null && useCacheNext) {
      // If the file exists in the cache, use it
      final cachedData = await cachedFile.file.readAsString();
      final decodedData = jsonDecode(cachedData);

      useCacheNext = false;

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

        useCacheNext = true;

        return artwork;
      } else {
        throw Exception('Failed to load artwork: ${response.reasonPhrase}');
      }
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

  /// Comments

  Future<List<Comment>> fetchCommentsByArtworkId(int artworkId) async {
    final response = await get('/artworks/comments/$artworkId');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.reasonPhrase}');
    }
  }

  Future<Comment> postComment(String content, String date, int artworkId, int userId) async {
    try {
      final response = await post(
        '/comments/',
        {
          'content': content,
          'date': date,
          'artwork': artworkId,
          'user': userId,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final fields = jsonResponse[0];
          return Comment.fromJson(fields);
        } else {
          throw Exception("Unexpected JSON format: $jsonResponse");
        }
      } else {
        throw Exception('Failed to post comment: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception("Failed to post comment due to an unexpected error.");
    }
  }

  Future<String> getUsernameById(int userId) async {
    try {
      final response = await get('/user');

      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
        final user = users.firstWhere((user) => user['pk'] == userId, orElse: () => null);

        // Si se encuentra el usuario, devolver su campo `name`
        return user != null ? user['fields']['name'] : null;
      } else {
        throw Exception('Error al obtener usuarios: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error al obtener el nombre de usuario: $e');
    }
  }

  /// User

  Future<User?> authenticateUser(String userName, String password) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }

    final response = await post('/user/authenticate', {
      'userName': userName,
      'password': password,
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return User.fromJson(jsonResponse[0]);
    } else {
      return null;
    }
  }

  Future<String?> registerUser(String name, String userName, String email, String password) async {
    final response = await post('/user/create', {
      'name': name,
      'userName': userName,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return "success";
    } else if (response.statusCode == 401) {
      return "error";
    } else {
      return null;
    }
  }

  /// Favorites

  Future<List<Artwork>> getFavorites(int userId) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        return _favoritesBox.values.toList();
      }

      final response = await get('/user/liked/$userId');
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Artwork> favorites = jsonResponse.map((json) => Artwork.fromJson(json)).toList();

        for (var artwork in favorites) {
          _processImageDownloadAndSave(artwork, _favoritesBox);
        }

        return favorites;
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (_favoritesBox.isOpen) {
        return _favoritesBox.values.toList();
      } else {
        throw Exception("No local data available and failed to connect to server.");
      }
    }
  }

  Future<void> removeFavorite(int userId, int artworkId) async {
    final response = await delete('/user/liked/$userId/$artworkId');
    if (response.statusCode != 204) {
      throw Exception('Error deleting favorite');
    }
    final updatedFavorites = await getFavorites(userId);
    await _saveFavoritesToLocal(updatedFavorites);
  }

  Future<Artwork> addFavorite(int userId, int artworkId) async {
    final response = await post('/user/like', {
      'userId': userId,
      'artworkId': artworkId,
    });
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      Artwork artwork = Artwork.fromJson(jsonResponse);

      await _favoritesBox.add(artwork);
      final updatedFavorites = await getFavorites(userId);
      await _saveFavoritesToLocal(updatedFavorites);

      return artwork;
    } else {
      throw Exception('Error adding favorite');
    }
  }

  Future<bool> isArtworkFavorite(int userId, int artworkId) async {
    final response = await get('/user/isLiked/$userId/$artworkId');

    if (response.statusCode == 200) {
      return response.body.trim() == 'True';
    } else {
      throw Exception('Error fetching favorite status');
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

      await _spotlightArtworksBox.clear();
      final currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _metadataBox.put('lastRefreshDate', currentDateStr);

      for (var artwork in artworks) {
        _processImageDownloadAndSave(artwork, _spotlightArtworksBox);
      }

      return artworks;
    } else {
      throw Exception('Failed to load spotlight artworks: ${response.reasonPhrase}');
    }
  }

  Future<List<Museum>> fetchMuseums(double latActual, double longActual) async {
    try {
      final response = await post(
          '/analytic_engine/nearest-museums/', {
        "latitude": latActual,
        "longitude": longActual,
      });
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((museumJson) => Museum.fromJson(museumJson)).toList();
      } else {
        throw Exception('Failed to load museums: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching museums: ${e.toString()}');
    }
  }

  /// Private methods

  bool _shouldUseLocalData() {
    final lastRefreshDateStr = _metadataBox.get('lastRefreshDate');
    if (lastRefreshDateStr != null) {
      final lastRefreshDate = DateFormat('yyyy-MM-dd').parse(lastRefreshDateStr);
      final currentDate = DateTime.now();
      return currentDate.difference(lastRefreshDate).inDays < 1;
    }
    return false;
  }

  Future<void> _processImageDownloadAndSave(Artwork artwork, Box box) async {
    final receivePort = ReceivePort();
    final rootIsolateToken = ServicesBinding.rootIsolateToken!;
    await Isolate.spawn(_downloadImageInIsolate, [artwork.image, artwork.id.toString(), receivePort.sendPort, rootIsolateToken]);

    receivePort.listen((message) {
      if (message is String) {
        artwork.localImagePath = message;
        box.put(artwork.id, artwork);
      }
    });
  }

  static Future<void> _downloadImageInIsolate(List args) async {
    String imageUrl = args[0];
    String artworkId = args[1];
    SendPort sendPort = args[2];
    RootIsolateToken rootIsolateToken = args[3];

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$artworkId.jpg';
        final imageFile = File(imagePath);

        await imageFile.writeAsBytes(response.bodyBytes);

        if (await imageFile.exists()) {
          sendPort.send(imagePath);
        } else {
          print("Error: No se pudo guardar la imagen en $imagePath");
        }
      } else {
        print("Error al descargar la imagen: código de estado ${response.statusCode}");
      }
    } catch (e) {
      print("Error al intentar descargar y guardar la imagen: $e");
    }
  }

  Future<void> _saveFavoritesToLocal(List<Artwork> favorites) async {
    final directory = await getApplicationDocumentsDirectory();
    final oldImages = directory.listSync().where((file) => file.path.endsWith('.jpg'));
    for (var file in oldImages) {
      try {
        await file.delete();
      } catch (e) {
        print("Error al borrar la imagen ${file.path}: $e");
      }
    }

    await _favoritesBox.clear();

    for (var artwork in favorites) {
      artwork.localImagePath = await _downloadImage(artwork.image, artwork.id.toString());
      await _favoritesBox.put(artwork.id, artwork);
    }
  }

  Future<String?> _downloadImage(String imageUrl, String artworkId) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$artworkId.jpg';
        final imageFile = File(imagePath);

        await imageFile.writeAsBytes(response.bodyBytes);

        if (await imageFile.exists()) {
          return imagePath;
        } else {
          print("Error: No se pudo guardar la imagen en $imagePath");
          return null;
        }
      } else {
        print("Error al descargar la imagen: código de estado ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error al intentar descargar y guardar la imagen: $e");
      return null;
    }
  }
}
