class UserModel {
  String id;
  String level;
  String username;
  String email;

  UserModel({
    required this.id,
    required this.level,
    required this.username,
    required this.email,
  });

  // Convert a UserModel object to a map (for Firestore or JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'username': username,
      'email': email,
    };
  }

  // Create a UserModel object from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      level: map['level'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
