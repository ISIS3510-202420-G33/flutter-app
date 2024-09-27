import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAdapter {
  // URL base para el backend
  final String baseUrl = 'http://34.170.38.233:8000';

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
