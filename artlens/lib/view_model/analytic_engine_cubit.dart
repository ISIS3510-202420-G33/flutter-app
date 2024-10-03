import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../model/analytic_engine_service.dart';


abstract class AnalyticEngineState {}

class AnalyticEngineInitial extends AnalyticEngineState {}

class AnalyticEngineLoading extends AnalyticEngineState {}

class AnalyticEngineLoaded extends AnalyticEngineState {
  final List<Artwork> recommendationsByUserId;

  AnalyticEngineLoaded(this.recommendationsByUserId);
}

class AnalyticEngineError extends AnalyticEngineState {
  final String message;

  AnalyticEngineError(this.message);
}

class AnalyticEngineCubit extends Cubit<AnalyticEngineState> {
  final AnalyticEngineService analyticEngineService;

  AnalyticEngineCubit(this.analyticEngineService) : super(AnalyticEngineInitial());

  Future<void> fetchRecommendationsByUserId(int id) async {
    try {
      emit(AnalyticEngineLoading());
      final recommendationsByUserId = await analyticEngineService.fetchRecommendationsByUserId(id);
      emit(AnalyticEngineLoaded(recommendationsByUserId));
    } catch (e) {
      emit(AnalyticEngineError('Error fetching recommendations by user id: ${e.toString()}'));
    }
  }

  void clearRecommendations() {
    emit(AnalyticEngineLoaded([]));
  }
}