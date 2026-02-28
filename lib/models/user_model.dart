class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? createdAt;

  User({
    this.id, 
    required this.name, 
    required this.email, 
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}
