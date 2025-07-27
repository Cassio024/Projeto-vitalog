// NOVO ARQUIVO: lib/services/auth_service.dart
// Serviço que encapsula toda a lógica de autenticação.
import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  // StreamController para gerenciar o estado do usuário.
  // O '.broadcast()' permite múltiplos ouvintes.
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();

  // Stream pública para que os widgets possam ouvir as mudanças de auth.
  Stream<UserModel?> get user => _userController.stream;

  // Usuário de exemplo para simulação
  static final Map<String, dynamic> _mockUserDatabase = {
    'test@test.com': {
      'uid': '12345',
      'name': 'Usuário Teste',
      'password': 'password123'
    }
  };

  // Simula o login
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula latência de rede

    if (_mockUserDatabase.containsKey(email) && _mockUserDatabase[email]!['password'] == password) {
      final userData = _mockUserDatabase[email]!;
      final user = UserModel(uid: userData['uid'], name: userData['name'], email: email);
      _userController.add(user); // Emite o usuário logado para o stream
      return user;
    } else {
      _userController.add(null);
      return null;
    }
  }

  // Simula o registro
  Future<UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUserDatabase.containsKey(email)) {
      // Usuário já existe
      return null;
    }

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    _mockUserDatabase[email] = {
      'uid': uid,
      'name': name,
      'password': password
    };
    
    final user = UserModel(uid: uid, name: name, email: email);
    // Não faz login automático, apenas registra. O usuário precisará logar.
    return user;
  }

  // Simula o logout
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _userController.add(null); // Emite nulo para o stream, indicando logout
  }

  // Fecha o stream controller quando não for mais necessário
  void dispose() {
    _userController.close();
  }
}