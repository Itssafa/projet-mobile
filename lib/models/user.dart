class User {
  final String username;
  final String email;
  final String role; // 'admin', 'veterinarian', 'caretaker'
  final DateTime? lastLogin;

  User({
    required this.username,
    required this.email,
    required this.role,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }
}

