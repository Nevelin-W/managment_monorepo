class User {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;
  final String? token;
  final String? idToken;
  final String? refreshToken;

  const User({
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
      token: json['token'],
      idToken: json['idToken'],
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

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? emailVerified,
    String? token,
    String? idToken,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      emailVerified: emailVerified ?? this.emailVerified,
      token: token ?? this.token,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id && email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, emailVerified: $emailVerified)';
  }
}