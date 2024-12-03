import 'package:artlens/view_model/connectivity_cubit.dart';
import 'package:artlens/view_model/search_cubit.dart';
import 'package:artlens/view_model/spotlight_artworks_cubit.dart';
import 'package:artlens/view_model/recommendations_cubit.dart';
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
import 'isFavorite_cubit.dart';
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
  final ConnectivityCubit connectivityCubit;
  final IsFavoriteCubit isFavoriteCubit;
  final FirestoreService firestoreService;

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
      this.museumArtworkCubit,
      this.connectivityCubit,
      this.isFavoriteCubit,
      this.firestoreService
      );

  // Métodos para manejar la búsqueda
  void fetchInitialSearchData() {
    searchCubit.fetchAllData();
  }

  void filterSearchResults(String query) {
    searchCubit.filterData(query);
  }

  // Authentication
  Future<void> authenticateUser(String username, String password) async {
    try {
      User? user = await userService.authenticateUser(username, password);
      if (user != null) {
        authCubit.logIn(user);  // Actualiza AuthCubit al estado autenticado
        print("User data saved: ${user.userName}");
      } else {
        authCubit.logOut();  // Asegura que el estado sea no autenticado si falla el inicio de sesión
      }
    } catch (e) {
      // Si la excepción es causada por falta de conexión, maneja el error de manera específica
      if (e.toString() == 'Exception: No internet connection') {
        print("No internet connection. Please check your network.");
        // Aquí podrías manejar la notificación en la UI, si es necesario.
      } else {
        print("An unexpected error occurred: $e");
      }

      authCubit.logOut();  // Asegura que el estado sea no autenticado en caso de error
      rethrow;  // Opcionalmente, lanza la excepción de nuevo para manejarla en la UI
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
  void fetchArtworkAndRelatedEntities(int artworkId) {
    artworkCubit.fetchArtworkAndRelatedEntities(artworkId);
  }

  void fetchArtworksByArtistId(int id) {
    artworkCubit.fetchArtworksByArtistId(id);
  }

  void fetchArtworkById(int id) {
    artworkCubit.fetchArtworkById(id);
  }

  void fetchArtworksByMuseumId(int museumId) {
    museumArtworkCubit.fetchArtworksByMuseumId(museumId);
  }

  void fetchCommentsByArtworkId(int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      commentsCubit.fetchCommentsByArtworkId(artworkId, userId);
    }
  }

  // Artist management
  void fetchArtistById(int id) {
    artistCubit.fetchArtistById(id);
  }

  void fetchAllArtists() {
    artistCubit.fetchArtists();
  }

  // Museum management
  void fetchMuseumById(int id) {
    museumCubit.fetchMuseumById(id);
  }

  void fetchAllMuseums() {
    museumCubit.fetchMuseums();
  }

  // Favorites management
  void fetchFavorites() async {
    final userId = await _getUserId();
    if (userId != null) {
      favoritesCubit.fetchFavorites(userId);
    }
  }

  Future<void> addFavorite(int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      favoritesCubit.addFavorite(userId, artworkId);
    }
  }

  Future<void> removeFavorite(int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      favoritesCubit.removeFavorite(userId, artworkId);
    }
  }

  void isArtworkLiked(int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      isFavoriteCubit.isArtworkLiked(userId, artworkId);
    }
  }

  // Helper para obtener el ID del usuario de SharedPreferences
  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void clearRecommendations() {
    recommendationsCubit.clearRecommendations();
  }

  // Comments management
  void postComment(String content, String date, int artworkId) async {
    final userId = await _getUserId();
    if (userId != null) {
      commentsCubit.postComment(content, date, artworkId, userId);
    }
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

  // Analytic engine
  void fetchRecommendationsByUserId() async {
    final userId = await _getUserId();
    if (userId != null) {
      recommendationsCubit.fetchRecommendationsByUserId(userId);
    } else {
      recommendationsCubit.clearRecommendations();
    }
  }

  void fetchSpotlightArtworks() {
    spotlightArtworksCubit.fetchSpotlightArtworks();
  }

  // Firebase
  void addDocument(String collectionName, Map<String, dynamic> data) {
    firestoreService.addDocument(collectionName, data);
  }

}
