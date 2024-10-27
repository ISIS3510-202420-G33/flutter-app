import 'package:bloc/bloc.dart';
import '../entities/artwork.dart';
import '../model/analytic_engine_service.dart';

abstract class RecommendationsState {}

class RecommendationsInitial extends RecommendationsState {}

class RecommendationsLoading extends RecommendationsState {}

class RecommendationsLoaded extends RecommendationsState {
  final List<Artwork> recommendationsByUserId;

  RecommendationsLoaded(this.recommendationsByUserId);
}

class RecommendationsError extends RecommendationsState {
  final String message;

  RecommendationsError(this.message);
}

class RecommendationsCubit extends Cubit<RecommendationsState> {
  final AnalyticEngineService analyticEngineService;

  RecommendationsCubit(this.analyticEngineService) : super(RecommendationsInitial());

  Future<void> fetchRecommendationsByUserId(int id) async {
    try {
      emit(RecommendationsLoading());
      final recommendationsByUserId = await analyticEngineService.fetchRecommendationsByUserId(id);
      emit(RecommendationsLoaded(recommendationsByUserId));
    } catch (e) {
      emit(RecommendationsError('Error fetching recommendations by user ID: ${e.toString()}'));
    }
  }

  void clearRecommendations() {
    emit(RecommendationsLoaded([]));
  }
}
