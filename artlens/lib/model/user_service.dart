import 'dart:convert';
import '../entities/artwork.dart';
import '../entities/user.dart';
import '../model/api_adapter.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<User?> authenticateUser(String userName, String password) async {
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

  // Add registration logic
  Future<String?> registerUser(String name, String userName, String email, String password) async {
    final response = await apiAdapter.post('/user/create', {
      'name': name,
      'userName': userName,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return "success";  // Registration successful
    } else if (response.statusCode == 401) {
      return "error";  // User already exists or other error
    } else {
      return null;  // Handle unexpected errors
    }
  }

  Future<List<Artwork>> getFavorites(int userId) async {
    final response = await apiAdapter.get('/user/liked/$userId');
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => Artwork.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching favorites');
    }
  }

  Future<void> removeFavorite(int userId, int artworkId) async {
    final response = await apiAdapter.delete('/user/liked/$userId/$artworkId');
    if (response.statusCode != 204) {
      throw Exception('Error deleting favorite');
    }
  }

  // Añadir un favorito y retornar la obra likeada
  Future<Artwork> addFavorite(int userId, int artworkId) async {
    final response = await apiAdapter.post('/user/like', {
      'userId': userId,
      'artworkId': artworkId,
    });
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Artwork.fromJson(jsonResponse);
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

}
