class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'email': email, 'name': name, 'isAdmin': isAdmin};
  }
}
