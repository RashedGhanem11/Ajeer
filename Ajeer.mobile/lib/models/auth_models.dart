class LoginRequest {
  final String identifier;
  final String password;

  LoginRequest({required this.identifier, required this.password});

  Map<String, dynamic> toJson() {
    return {'identifier': identifier, 'password': password};
  }
}

class AuthResponse {
  final String token;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profilePictureUrl;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePictureUrl,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'].toString(),
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}

class UserRegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;

  UserRegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone, 'password': password};
  }
}
