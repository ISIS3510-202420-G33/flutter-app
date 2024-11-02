import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../model/user_service.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Artwork> favorites;

  FavoritesLoaded(this.favorites);
}

class IsLikedLoaded extends FavoritesState {
  final bool isLiked;

  IsLikedLoaded(this.isLiked);
}

class Error extends FavoritesState {
  final String message;

  Error(this.message);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final UserService userService;

  FavoritesCubit(this.userService) : super(FavoritesInitial());

  Future<void> fetchFavorites(int userId) async {
    emit(FavoritesLoading());
    try {
      print("Fetching favorites for user $userId");
      final favorites = await userService.getFavorites(userId);
      print("Favorites loaded: ${favorites.length} items");
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      print("Error fetching favorites: $e");
      emit(Error('Error fetching favorites'));
    }
  }


  Future<void> removeFavorite(int userId, int artworkId) async {
    emit(FavoritesLoading());
    try {
      await userService.removeFavorite(userId, artworkId);
      // Obtener y emitir la lista actualizada de favoritos
      final updatedFavorites = await userService.getFavorites(userId);
      emit(FavoritesLoaded(updatedFavorites));
    } catch (e) {
      emit(Error('Error deleting favorite'));
    }
  }

  Future<void> addFavorite(int userId, int artworkId) async {
    emit(FavoritesLoading());
    try {
      await userService.addFavorite(userId, artworkId);
      // Obtener y emitir la lista actualizada de favoritos
      final updatedFavorites = await userService.getFavorites(userId);
      emit(FavoritesLoaded(updatedFavorites));
    } catch (e) {
      emit(Error('Error adding favorite'));
    }
  }

  Future<void> isArtworkLiked(int userId, int artworkId) async {
    try {
      final isLiked = await userService.isArtworkFavorite(userId, artworkId);
      emit(IsLikedLoaded(isLiked));
    } catch (e) {
      emit(Error('Error getting if artwork is liked'));
    }
  }
}
