import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAdapter {
  // URL base para el backend
  final String baseUrl = 'http://192.168.11.24:8000';

  // Constructor privado para implementar el Singleton
  ApiAdapter._privateConstructor();

  // Instancia única de la clase
  static final ApiAdapter _instance = ApiAdapter._privateConstructor();

  // Método para obtener la instancia
  static ApiAdapter get instance => _instance;

  // Método para hacer peticiones GET
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

// Aquí puedes añadir más métodos (POST, PUT, DELETE, etc.) si es necesario
}
