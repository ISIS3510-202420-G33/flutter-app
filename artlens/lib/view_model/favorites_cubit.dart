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
      final favorites = await userService.getFavorites(userId);
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(Error('Error fetching favorites'));
    }
  }


  Future<void> removeFavorite(int userId, int artworkId) async {
    emit(FavoritesLoading());
    try {
      await userService.removeFavorite(userId, artworkId);
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
      final updatedFavorites = await userService.getFavorites(userId);
      emit(FavoritesLoaded(updatedFavorites));
    } catch (e) {
      emit(Error('Error adding favorite'));
    }
  }
}
