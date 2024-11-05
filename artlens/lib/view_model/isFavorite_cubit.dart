import 'package:bloc/bloc.dart';
import '../model/user_service.dart';

abstract class IsFavoriteState {}

class IsFavoriteInitial extends IsFavoriteState {}

class IsFavoriteLoading extends IsFavoriteState {}

class IsLikedLoaded extends IsFavoriteState {
  final bool isLiked;

  IsLikedLoaded(this.isLiked);
}

class Error extends IsFavoriteState {
  final String message;

  Error(this.message);
}

class IsFavoriteCubit extends Cubit<IsFavoriteState> {
  final UserService userService;

  IsFavoriteCubit(this.userService) : super(IsFavoriteInitial());

  Future<void> isArtworkLiked(int userId, int artworkId) async {
    try {
      emit(IsFavoriteLoading());
      final isLiked = await userService.isArtworkFavorite(userId, artworkId);
      emit(IsLikedLoaded(isLiked));
    } catch (e) {
      emit(Error('Error getting if artwork is liked'));
    }
  }
}
