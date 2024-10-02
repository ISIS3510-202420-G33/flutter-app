import 'dart:convert';
import '../entities/museum.dart';
import '../model/api_adapter.dart';

class MapService {
  static final MapService _instance = MapService._internal();

  factory MapService() {
    return _instance;
  }

  MapService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  // Método para obtener los museos
  Future<List<Museum>> fetchMuseums() async {
    try {
      final response = await apiAdapter.get('/nearest-museums/'); // Cambia el endpoint según sea necesario
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((museumJson) => Museum.fromJson(museumJson)).toList();
      } else {
        throw Exception('Failed to load museums: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Manejo de errores en la llamada de API
      throw Exception('Error fetching museums: ${e.toString()}');
    }
  }
}
