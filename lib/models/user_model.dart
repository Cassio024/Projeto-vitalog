// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String? name;
  final String? email;

  UserModel({required this.uid, this.name, this.email});
}