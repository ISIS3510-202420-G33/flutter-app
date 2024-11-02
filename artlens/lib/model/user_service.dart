import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/artwork.dart';
import '../entities/user.dart';
import '../model/api_adapter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;
  final Box<Artwork> _favoritesBox = Hive.box<Artwork>('favoritesArtworks');

  Future<User?> authenticateUser(String userName, String password) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }

    final response = await apiAdapter.post('/user/authenticate', {
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
    final response = await apiAdapter.post('/user/create', {
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

  Future<List<Artwork>> getFavorites(int userId) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        print("No internet connection: loading from local storage.");
        final localFavorites = _favoritesBox.values.toList();
        print("Loaded ${localFavorites.length} favorites from local storage.");
        return localFavorites;
      }

      final response = await apiAdapter.get('/user/liked/$userId');
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Artwork> favorites = jsonResponse.map((json) => Artwork.fromJson(json)).toList();

        for (var artwork in favorites) {
          _processImageDownloadAndSave(artwork);
        }

        print("Favorites loaded from server.");
        return favorites;
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error in getFavorites: $e");
      if (_favoritesBox.isOpen) {
        print("Returning local data due to error.");
        return _favoritesBox.values.toList();
      } else {
        throw Exception("No local data available and failed to connect to server.");
      }
    }
  }

  Future<void> removeFavorite(int userId, int artworkId) async {
    final response = await apiAdapter.delete('/user/liked/$userId/$artworkId');
    if (response.statusCode != 204) {
      throw Exception('Error deleting favorite');
    }
    final updatedFavorites = await getFavorites(userId);
    await _saveFavoritesToLocal(updatedFavorites);
  }

  Future<Artwork> addFavorite(int userId, int artworkId) async {
    final response = await apiAdapter.post('/user/like', {
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
    final response = await apiAdapter.get('/user/isLiked/$userId/$artworkId');

    if (response.statusCode == 200) {
      return response.body.trim() == 'True';
    } else {
      throw Exception('Error fetching favorite status');
    }
  }

  Future<void> _processImageDownloadAndSave(Artwork artwork) async {
    final receivePort = ReceivePort();
    final rootIsolateToken = ServicesBinding.rootIsolateToken!;
    await Isolate.spawn(_downloadImageInIsolate, [artwork.image, artwork.id.toString(), receivePort.sendPort, rootIsolateToken]);

    receivePort.listen((message) {
      if (message is String) {
        artwork.localImagePath = message;
        _favoritesBox.put(artwork.id, artwork);
        print("Imagen guardada exitosamente en Hive para ${artwork.name}");
      }
    });
  }

  static Future<void> _downloadImageInIsolate(List args) async {
    String imageUrl = args[0];
    String artworkId = args[1];
    SendPort sendPort = args[2];
    RootIsolateToken rootIsolateToken = args[3];

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken); // Inicializar antes de usar plugins

    try {
      print("Intentando descargar imagen desde $imageUrl");
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$artworkId.jpg';
        final imageFile = File(imagePath);

        await imageFile.writeAsBytes(response.bodyBytes);

        if (await imageFile.exists()) {
          print("Imagen guardada en: $imagePath");
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
        print("Imagen borrada: ${file.path}");
      } catch (e) {
        print("Error al borrar la imagen ${file.path}: $e");
      }
    }

    await _favoritesBox.clear();

    for (var artwork in favorites) {
      artwork.localImagePath = await _downloadImage(artwork.image, artwork.id.toString());
      print("Ruta de imagen descargada para ${artwork.name}: ${artwork.localImagePath}");
      await _favoritesBox.put(artwork.id, artwork);
    }
    print('Favoritos guardados en almacenamiento local: ${favorites.length} elementos');
  }

  Future<String?> _downloadImage(String imageUrl, String artworkId) async {
    try {
      print("Intentando descargar imagen desde $imageUrl");

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$artworkId.jpg';
        final imageFile = File(imagePath);

        await imageFile.writeAsBytes(response.bodyBytes);

        if (await imageFile.exists()) {
          print("Imagen guardada en: $imagePath");
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
