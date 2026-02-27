class VaultEntry {
  final int? id;
  final int userId; // Owner of this entry
  final String title;
  final String username;
  final String encryptedPassword;
  final String category;
  final String? description;
  final double strengthScore;
  final bool isDeleted;

  VaultEntry({
    this.id,
    required this.userId,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    required this.category,
    this.description,
    this.strengthScore = 0.0,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'username': username,
      'encryptedPassword': encryptedPassword,
      'category': category,
      'description': description,
      'strengthScore': strengthScore,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory VaultEntry.fromMap(Map<String, dynamic> map) {
    return VaultEntry(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      username: map['username'],
      encryptedPassword: map['encryptedPassword'],
      category: map['category'],
      description: map['description'],
      strengthScore: map['strengthScore'] ?? 0.0,
      isDeleted: (map['isDeleted'] ?? 0) == 1,
    );
  }
}
