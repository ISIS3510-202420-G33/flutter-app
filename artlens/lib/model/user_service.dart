import 'dart:convert';
import '../entities/artwork.dart';
import '../entities/user.dart';
import '../model/api_adapter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;
  final Box<Artwork> _favoritesBox = Hive.box<Artwork>('favoritesArtworks'); // Caja de Hive para favoritos

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
      // Verificar conectividad
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        print("No internet connection: loading from local storage.");
        // Sin conexión: devolver datos locales desde Hive
        final localFavorites = _favoritesBox.values.toList();
        print("Loaded ${localFavorites.length} favorites from local storage.");
        return localFavorites;
      }

      // Con conexión: obtener datos del backend
      final response = await apiAdapter.get('/user/liked/$userId');
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Artwork> favorites = jsonResponse.map((json) => Artwork.fromJson(json)).toList();

        // Guardar los datos obtenidos en Hive para acceso offline
        await _saveFavoritesToLocal(favorites);
        print("Favorites loaded from server and saved locally.");

        return favorites;
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error in getFavorites: $e");
      if (_favoritesBox.isOpen) {
        // Intentar devolver los datos locales si Hive está disponible
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
    // Refrescar favoritos en Hive después de eliminar uno
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

      // Agregar el favorito a Hive y actualizar la lista completa
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
      if (response.body.trim() == 'True') {
        return true;
      } else if (response.body.trim() == 'False') {
        return false;
      } else {
        throw Exception('Formato de respuesta inesperado: ${response.body}');
      }
    } else {
      throw Exception('Error al obtener favoritos');
    }
  }

  // Guardar favoritos localmente en Hive
  Future<void> _saveFavoritesToLocal(List<Artwork> favorites) async {
    await _favoritesBox.clear();  // Limpiar datos antiguos
    for (var artwork in favorites) {
      await _favoritesBox.add(artwork);  // Guardar nuevos favoritos en Hive
    }
    print('Favorites saved to local storage: ${favorites.length} items'); // Mensaje de confirmación
  }

}
