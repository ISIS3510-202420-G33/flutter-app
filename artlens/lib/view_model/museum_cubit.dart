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

class MuseumsLoaded extends MuseumState {
  final List<Museum> museums;

  MuseumsLoaded(this.museums);
}

class Error extends MuseumState {
  final String message;

  Error(this.message);
}

class MuseumCubit extends Cubit<MuseumState> {
  final MuseumService museumService;

  MuseumCubit(this.museumService) : super(MuseumInitial());

  Future<void> fetchMuseumById(int id) async {
    emit(MuseumLoading());
    try {
      final museum = await museumService.fetchMuseumById(id);
      emit(MuseumLoaded(museum));
    } catch (e) {
      emit(Error('Error fetching museum: ${e.toString()}'));
    }
  }

  Future<void> fetchMuseums() async {
    emit(MuseumLoading());
    try {
      final museums = await museumService.fetchAllMuseums();
      emit(MuseumsLoaded(museums));
    } catch (e) {
      emit(Error('Error fetching museums: ${e.toString()}'));
    }
  }
}
