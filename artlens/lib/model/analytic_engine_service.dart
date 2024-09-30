import 'dart:convert';
import '../entities/artwork.dart';
import '../model/api_adapter.dart';

class AnalyticEngineService {
  static final AnalyticEngineService _instance = AnalyticEngineService._internal();

  factory AnalyticEngineService() {
    return _instance;
  }

  AnalyticEngineService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<List<Artwork>> fetchRecommendationsByUserId(int id) async {
    final response = await apiAdapter.get('/analytic_engine/recommend/$id');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Artwork.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load recommendations: ${response.reasonPhrase}');
    }
  }

}
