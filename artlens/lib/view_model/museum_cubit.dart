import 'package:bloc/bloc.dart';
import '../entities/museum.dart';
import '../model/museum_service.dart';

abstract class MuseumState {}

class MuseumInitial extends MuseumState {}

class MuseumLoading extends MuseumState {}

class MuseumLoaded extends MuseumState {
  final Museum museum;

  MuseumLoaded(this.museum);
}

class MuseumError extends MuseumState {
  final String message;

  MuseumError(this.message);
}

class MuseumCubit extends Cubit<MuseumState> {
  final MuseumService museumService;

  MuseumCubit(this.museumService) : super(MuseumInitial());

  Future<void> fetchMuseumById(int id) async {
    try {
      emit(MuseumLoading());
      final museum = await museumService.fetchMuseumById(id);
      emit(MuseumLoaded(museum));
    } catch (e) {
      emit(MuseumError('Error fetching museum: ${e.toString()}'));
    }
  }
}
