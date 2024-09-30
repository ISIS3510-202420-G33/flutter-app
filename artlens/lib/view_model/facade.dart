import '../entities/artwork.dart';
import '../entities/user.dart';
import '../view_model/artwork_cubit.dart';
import '../view_model/artist_cubit.dart';
import '../view_model/museum_cubit.dart';
import '../view_model/auth_cubit.dart';
import '../view_model/favorites_cubit.dart';
import '../view_model/analytic_engine_cubit.dart';
import '../view_model/comments_cubit.dart';
import '../model/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFacade {
  final ArtworkCubit artworkCubit;
  final ArtistCubit artistCubit;
  final CommentsCubit commentsCubit;
  final MuseumCubit museumCubit;
  final AuthCubit authCubit;
  final FavoritesCubit favoritesCubit;
  final UserService userService;
  final AnalyticEngineCubit analyticEngineCubit;


  AppFacade({
    required this.artworkCubit,
    required this.artistCubit,
    required this.commentsCubit,
    required this.museumCubit,
    required this.authCubit,
    required this.favoritesCubit,
    required this.userService,
    required this.analyticEngineCubit
  });

  // Authentication
  Future<void> authenticateUser(String username, String password) async {
    try {
      User? user = await userService.authenticateUser(username, password);
      if (user != null) {
        await _saveUserToPreferences(user);  // Save user info to shared preferences
        authCubit.logIn(user);  // Update AuthCubit to authenticated state
        print("User data saved: ${user.userName}");
      } else {
        authCubit.logOut();  // Ensure the state is unauthenticated if login fails
      }
    } catch (e) {
      authCubit.logOut();  // Ensure state is unauthenticated on error
      rethrow;  // Optionally, throw the error again to handle it in the UI
    }
  }

  // Registration
  Future<String?> registerUser(String name, String userName, String email, String password) async {
    return await userService.registerUser(name, userName, email, password);
  }

  void logOut() async {
    await _clearPreferences();  // Clear the saved session
    authCubit.logOut();  // Change state to unauthenticated
  }

  bool isLoggedIn() {
    return authCubit.isLoggedIn();  // Check if user is authenticated
  }

  // Load session from shared preferences
  Future<void> loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      String name = prefs.getString('name') ?? '';
      String userName = prefs.getString('userName') ?? '';
      String email = prefs.getString('email') ?? '';

      User user = User(
        id: userId,
        name: name,
        userName: userName,
        email: email,
        likedArtworks: [],  // You can manage likedArtworks separately
      );

      authCubit.logIn(user);  // Log in with the loaded user data
    }
  }

  // Helper method to save user data to shared preferences
  Future<void> _saveUserToPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id);
    await prefs.setString('name', user.name);
    await prefs.setString('userName', user.userName);
    await prefs.setString('email', user.email);
  }

  // Helper method to clear session data from shared preferences
  Future<void> _clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // This will clear all stored user data
  }

  // Artwork management
  void fetchArtworkAndRelatedEntities(int id) {
    artworkCubit.fetchArtworkAndRelatedEntities(id);
  }

  void fetchArtworksByArtistId(int id) {
    artworkCubit.fetchArtworksByArtistId(id);
  }

  void fetchArtworkById(int id) {
    artworkCubit.fetchArtworkById(id);
  }

  // Artist management
  void fetchArtistById(int id) {
    artistCubit.fetchArtistById(id);
  }

  // Museum management
  void fetchMuseumById(int id) {
    museumCubit.fetchMuseumById(id);
  }

  void fetchRecommendationsByUserId(int id) {
    analyticEngineCubit.fetchRecommendationsByUserId(id);
  }

  // Favorites management (nuevo)

  // Obtener los favoritos del usuario
  Future<List<Artwork>> fetchFavorites() async {
    final userId = await _getUserId();
    if (userId != null) {
      final favorites = favoritesCubit.fetchFavorites(userId);
      return favorites;
    }
    return [];
  }

  Future<void> addFavorite(int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      await favoritesCubit.addFavorite(userId, artworkId);
    }
  }

  // Eliminar un favorito del usuario
  Future<void> removeFavorite(int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      favoritesCubit.removeFavorite(userId, artworkId);
    }
  }

  // Helper para obtener el ID del usuario de SharedPreferences
  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Obtener comentarios de una obra de arte
  Future<void> fetchCommentsByArtworkId(int artworkId) async {
    await commentsCubit.fetchCommentsByArtworkId(artworkId);
  }

  // Publicar un comentario en una obra de arte
  Future<void> postComment(String content, String date, int artworkId) async {
    final userId = await _getUserId();  // Obtén el ID del usuario autenticado
    if (userId != null) {
      await commentsCubit.postComment(content, date, artworkId, userId);
    }
  }

  // Método para obtener el nombre de usuario por ID
  Future<String?> getUsername(int userId) async {
    await commentsCubit.fetchUsername(userId);
    if (commentsCubit.state is CommentsLoaded) {
      return (commentsCubit.state as CommentsLoaded).username;
    }
    return null;
  }
}
