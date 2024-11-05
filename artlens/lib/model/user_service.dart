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
    return await apiAdapter.authenticateUser(userName, password);
  }

  Future<String?> registerUser(String name, String userName, String email, String password) async {
    return await apiAdapter.registerUser(name, userName, email, password);
  }

  Future<List<Artwork>> getFavorites(int userId) async {
    return await apiAdapter.getFavorites(userId);
  }

  Future<void> removeFavorite(int userId, int artworkId) async {
    return await apiAdapter.removeFavorite(userId, artworkId);
  }

  Future<Artwork> addFavorite(int userId, int artworkId) async {
    return await apiAdapter.addFavorite(userId, artworkId);
  }

  Future<bool> isArtworkFavorite(int userId, int artworkId) async {
    return await apiAdapter.isArtworkFavorite(userId, artworkId);
  }

}
