class User {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;
  final String? token;          // Access token (optional, for future use)
  final String? idToken;        // ID token (required for API Gateway)
  final String? refreshToken;   // Refresh token (optional)

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
    this.token,
    this.idToken,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      token: json['token'],           // Access token
      idToken: json['idToken'],       // ID token
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'emailVerified': emailVerified,
      if (token != null) 'token': token,
      if (idToken != null) 'idToken': idToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, emailVerified: $emailVerified)';
  }
}