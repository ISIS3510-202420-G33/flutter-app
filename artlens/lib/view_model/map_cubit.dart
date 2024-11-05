import 'package:artlens/model/analytic_engine_service.dart';
import 'package:bloc/bloc.dart';
import '../entities/museum.dart';

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
  final AnalyticEngineService analyticEngineService;

  MapCubit(this.analyticEngineService) : super(MapState(museums: []));

  Future<List<Museum>> fetchMuseums(double latActual, double longActual) async {
    emit(MapState(museums: state.museums, isLoading: true));
    try {
      final museums = await analyticEngineService.fetchMuseums(latActual, longActual);
      emit(MapState(museums: museums, isLoading: false));
      return museums;
    } catch (e) {
      emit(MapState(museums: [], isLoading: false, error: 'Error fetching museums: ${e.toString()}'));
      return [];
    }
  }
}
