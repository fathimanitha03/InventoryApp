import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _buildHeaders({String? token}) async {
    final authToken = token ?? await _authService.getToken();

    return {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };
  }

  Future<http.Response> get({
    required String baseUrl,
    required String endpoint,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(token: token);
    return http.get(url, headers: headers);
  }

  Future<http.Response> post({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(token: token);

    return http.post(
      url,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> put({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(token: token);

    return http.put(
      url,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> delete({
    required String baseUrl,
    required String endpoint,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(token: token);
    return http.delete(url, headers: headers);
  }
}