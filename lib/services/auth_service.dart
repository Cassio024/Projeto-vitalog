// Arquivo: lib/services/auth_service.dart
// MODIFICADO: Adicionados métodos simulados para redefinição de senha.
import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get user => _userController.stream;

  static final Map<String, dynamic> _mockUserDatabase = {
    'test@test.com': {
      'uid': '12345',
      'name': 'Usuário Teste',
      'password': 'password123'
    }
  };

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); 

    if (_mockUserDatabase.containsKey(email) && _mockUserDatabase[email]!['password'] == password) {
      final userData = _mockUserDatabase[email]!;
      final user = UserModel(uid: userData['uid'], name: userData['name'], email: email);
      _userController.add(user);
      return user;
    } else {
      _userController.add(null);
      return null;
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUserDatabase.containsKey(email)) {
      return null;
    }

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    _mockUserDatabase[email] = {
      'uid': uid,
      'name': name,
      'password': password
    };
    
    final user = UserModel(uid: uid, name: name, email: email);
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _userController.add(null);
  }
  
  // NOVO MÉTODO: Simula o envio de um código de redefinição.
  Future<bool> sendPasswordResetCode(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    // Lógica de simulação: se o email existir no nosso mock database, consideramos sucesso.
    if (_mockUserDatabase.containsKey(email)) {
      print('SIMULAÇÃO: Código de redefinição "123456" enviado para $email');
      return true;
    }
    return false;
  }
  
  // NOVO MÉTODO: Simula a redefinição da senha com o código.
  Future<bool> resetPassword(String code, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    // Lógica de simulação: qualquer código "123456" é aceito.
    if (code == '123456') {
       print('SIMULAÇÃO: Senha redefinida com sucesso!');
       return true;
    }
    return false;
  }

  void dispose() {
    _userController.close();
  }
}
