import 'package:artlens/view_model/search_cubit.dart';
import 'package:artlens/view_model/spotlight_artworks_cubit.dart';
import 'package:artlens/view_model/recommendations_cubit.dart';
import '../entities/artwork.dart';
import '../entities/comment.dart';
import '../entities/user.dart';
import '../entities/museum.dart';
import '../model/firestore_service.dart';
import '../view_model/artwork_cubit.dart';
import '../view_model/artist_cubit.dart';
import '../view_model/museum_cubit.dart';
import '../view_model/auth_cubit.dart';
import '../view_model/favorites_cubit.dart';
import '../view_model/comments_cubit.dart';
import '../view_model/map_cubit.dart';
import '../model/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'museum_artwork_cubit.dart';

class AppFacade {
  final ArtworkCubit artworkCubit;
  final ArtistCubit artistCubit;
  final CommentsCubit commentsCubit;
  final MuseumCubit museumCubit;
  final AuthCubit authCubit;
  final FavoritesCubit favoritesCubit;
  final UserService userService;
  final MapCubit mapCubit;
  final SpotlightArtworksCubit spotlightArtworksCubit;
  final RecommendationsCubit recommendationsCubit;
  final SearchCubit searchCubit;
  final MuseumArtworkCubit museumArtworkCubit;
  AppFacade(
      this.artworkCubit,
      this.artistCubit,
      this.commentsCubit,
      this.museumCubit,
      this.authCubit,
      this.favoritesCubit,
      this.userService,
      this.mapCubit,
      this.spotlightArtworksCubit,
      this.recommendationsCubit,
      this.searchCubit,
      this.museumArtworkCubit
      );

  // Métodos para manejar la búsqueda
  Future<void> fetchInitialSearchData() async {
    await searchCubit.fetchAllData();
  }

  void filterSearchResults(String query) {
    searchCubit.filterData(query);
  }

  // Authentication
  Future<void> authenticateUser(String username, String password) async {
    try {
      User? user = await userService.authenticateUser(username, password);
      if (user != null) {
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
    recommendationsCubit.fetchRecommendationsByUserId(id);
  }

  // Favorites management

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
  Future<List<Comment>> fetchCommentsByArtworkId(int artworkId) async {
    try {
      final comments = await commentsCubit.fetchCommentsByArtworkId(artworkId);
      return comments;
    } catch (e) {
      // Manejo de errores
      print('Error fetching museums: $e');
      return [];
    }
  }

  void clearRecommendations() {
    recommendationsCubit.clearRecommendations();
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

  // Obtener la lista de museos
  Future<List<Museum>> fetchMuseums(double latActual, double longActual) async {
    try {
      final museums = await mapCubit.fetchMuseums(latActual, longActual);
      return museums;
    } catch (e) {
      // Manejo de errores
      print('Error fetching museums: $e');
      return [];
    }
  }

  void fetchSpotlightArtworks() {
    spotlightArtworksCubit.fetchSpotlightArtworks();
  }

  Future<void> fetchArtworksByMuseumId(int museumId) async {
    await museumArtworkCubit.fetchArtworksByMuseumId(museumId);
  }

}
