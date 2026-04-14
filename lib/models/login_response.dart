class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final String username;
  final String role;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    required this.username,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    return LoginResponse(
      success: json['success'] ?? json['isSuccess'] ?? true,
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ??
          data['token']?.toString() ??
          data['accessToken']?.toString() ??
          '',
      refreshToken: json['refreshToken']?.toString() ??
          data['refreshToken']?.toString() ??
          '',
      username: data['username']?.toString() ??
          json['username']?.toString() ??
          '',
      role: data['role']?.toString() ??
          json['role']?.toString() ??
          '',
    );
  }
}