import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../utils/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';
  static const String _storeIdKey = 'store_id';
  static const String _mobileLoggedInKey = 'mobile_logged_in';

  Future<bool> mobileLogin({required String storeId}) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.mobileLogin}',
    );

    final response = await http.post(
      url,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({"storeId": storeId}),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mobileLoggedInKey, true);
      await prefs.setString(_storeIdKey, storeId);
      return true;
    }

    throw Exception('Mobile login failed');
  }

  Future<LoginResponse> adminLogin({
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.login}',
    );

    final request = LoginRequest(
      username: username,
      password: password,
      rememberMe: rememberMe,
    );

    final response = await http.post(
      url,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = LoginResponse.fromJson(data);

      if (result.token.isEmpty) {
        throw Exception('Token not received from server');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token);
      await prefs.setString(_refreshTokenKey, result.refreshToken);
      await prefs.setString(_usernameKey, result.username);
      await prefs.setString(_roleKey, result.role);

      return result;
    }

    String message = 'Admin login failed';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        message = body['message']?.toString() ?? message;
      }
    } catch (_) {}

    throw Exception(message);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_storeIdKey);
    await prefs.remove(_mobileLoggedInKey);
  }
}