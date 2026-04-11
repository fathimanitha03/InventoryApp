import '../models/login_response.dart';

class AuthService {
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (username == 'admin' && password == '1234') {
      return LoginResponse(
        success: true,
        message: 'Login successful',
        token: 'hardcoded_token_123',
      );
    } else {
      throw Exception('Invalid username or password');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}