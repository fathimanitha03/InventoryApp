import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<http.Response> get({
    required String baseUrl,
    required String endpoint,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> post({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body ?? {}),
    );
  }
}