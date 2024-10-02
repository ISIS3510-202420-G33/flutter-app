import 'package:bloc/bloc.dart';
import '../entities/museum.dart';
import '../model/map_service.dart';

class MapState {
  final List<Museum> museums;
  final bool isLoading;
  final String? error;

  MapState({
    required this.museums,
    this.isLoading = false,
    this.error,
  });
}

class MapCubit extends Cubit<MapState> {
  final MapService mapService;

  MapCubit(this.mapService) : super(MapState(museums: []));

  // Método para obtener los museos
  Future<List<Museum>> fetchMuseums() async {
    emit(MapState(museums: state.museums, isLoading: true));
    try {
      final museums = await mapService.fetchMuseums();
      emit(MapState(museums: museums, isLoading: false));
      return museums; // Devuelve la lista de museos
    } catch (e) {
      emit(MapState(museums: [], isLoading: false, error: 'Error fetching museums: ${e.toString()}'));
      return []; // Devuelve una lista vacía en caso de error
    }
  }
}
