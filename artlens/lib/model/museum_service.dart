import 'dart:convert';
import '../entities/museum.dart';
import '../model/api_adapter.dart';

class MuseumService {
  static final MuseumService _instance = MuseumService._internal();

  factory MuseumService() {
    return _instance;
  }

  MuseumService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<Museum> fetchMuseumById(int id) async {
    final response = await apiAdapter.get('/museums/$id');
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return Museum.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Failed to load museum: ${response.reasonPhrase}');
    }
  }

}
