// NOVO ARQUIVO: lib/models/user_model.dart
// Modelo simples para representar o usuário logado.
class UserModel {
  final String uid;
  final String? name;
  final String? email;

  UserModel({required this.uid, this.name, this.email});
}
