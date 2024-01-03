// ignore_for_file: public_member_api_docs, sort_constructors_first
// user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar
    };
  }
}
