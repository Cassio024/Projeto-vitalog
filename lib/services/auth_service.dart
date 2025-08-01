// Arquivo: lib/services/auth_service.dart
// CORRIGIDO: Sintaxe das importações 'dart:async' e 'dart:convert'.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get user => _userController.stream;

  Future<Map<String, dynamic>> registerWithEmailAndPassword(String name, String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['msg'] ?? 'Erro desconhecido'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Não foi possível conectar ao servidor.'};
    }
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        // AINDA SIMULADO: O gerenciamento de token será o próximo passo.
        _userController.add(UserModel(uid: 'temp_id', email: email));
        return {'success': true, 'data': responseData};
      } else {
        _userController.add(null);
        return {'success': false, 'message': responseData['msg'] ?? 'Credenciais inválidas'};
      }
    } catch (error) {
      _userController.add(null);
      return {'success': false, 'message': 'Não foi possível conectar ao servidor.'};
    }
  }

  // NOVO: Envia o pedido de código para a API
  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['msg']};
      } else {
        return {'success': false, 'message': responseData['msg'] ?? 'Erro ao solicitar código.'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Não foi possível conectar ao servidor.'};
    }
  }

  // NOVO: Envia os dados de redefinição para a API
  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code, 'password': newPassword}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['msg']};
      } else {
        return {'success': false, 'message': responseData['msg'] ?? 'Erro ao redefinir senha.'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Não foi possível conectar ao servidor.'};
    }
  }

  Future<void> signOut() async {
    _userController.add(null);
  }

  void dispose() {
    _userController.close();
  }
}
