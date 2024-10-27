import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAdapter {
  final String baseUrl = 'http://192.168.11.22:8000';

  static final ApiAdapter _instance = ApiAdapter._privateConstructor();

  ApiAdapter._privateConstructor();

  static ApiAdapter get instance => _instance;

  // Method for POST requests
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // Method for GET requests
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // Method for DELETE requests
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url);
      return response;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}
