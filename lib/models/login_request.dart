class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.username,
    required this.password,
    required this.rememberMe,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "rememberMe": rememberMe,
    };
  }
}