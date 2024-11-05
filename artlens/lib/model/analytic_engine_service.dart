import '../entities/artwork.dart';
import '../entities/museum.dart';
import '../model/api_adapter.dart';

class AnalyticEngineService {
  static final AnalyticEngineService _instance = AnalyticEngineService._internal();
  final ApiAdapter apiAdapter = ApiAdapter.instance;

  factory AnalyticEngineService() {
    return _instance;
  }

  AnalyticEngineService._internal();

  Future<List<Artwork>> fetchRecommendationsByUserId(int id) async {
    return await apiAdapter.fetchRecommendationsByUserId(id);
  }

  Future<List<Artwork>> fetchSpotlightArtworks() async {
    return await apiAdapter.fetchSpotlightArtworks();
  }

  Future<List<Museum>> fetchMuseums(double latActual, double longActual) async {
    return await apiAdapter.fetchMuseums(latActual, longActual);
  }
}
