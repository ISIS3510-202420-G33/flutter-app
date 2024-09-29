import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../model/user_service.dart';

class FavoritesState {
  final List<Artwork> favorites;
  final bool isLoading;
  final String? error;

  FavoritesState({
    required this.favorites,
    this.isLoading = false,
    this.error,
  });
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final UserService userService;

  FavoritesCubit(this.userService) : super(FavoritesState(favorites: []));

  // Método para obtener los favoritos del usuario
  Future<void> fetchFavorites(int userId) async {
    emit(FavoritesState(favorites: [], isLoading: true));
    try {
      final favorites = await userService.getFavorites(userId);
      emit(FavoritesState(favorites: favorites));
    } catch (e) {
      emit(FavoritesState(favorites: [], error: 'Error fetching favorites'));
    }
  }

  // Método para eliminar un favorito
  Future<void> removeFavorite(int userId, int artworkId) async {
    try {
      await userService.removeFavorite(userId, artworkId);
      final updatedFavorites = state.favorites
          .where((artwork) => artwork.id != artworkId)
          .toList();
      emit(FavoritesState(favorites: updatedFavorites));
    } catch (e) {
      emit(FavoritesState(favorites: state.favorites, error: 'Error deleting favorite'));
    }
  }
}
