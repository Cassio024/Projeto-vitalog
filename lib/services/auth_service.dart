import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get user => _userController.stream;
  String? _token;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return;
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedUserData['token'];
    _userController.add(UserModel(uid: 'auto_logged_in'));
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    // ...código de login... (sem alterações)
     final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        _token = responseData['token'];
        _userController.add(UserModel(uid: 'logged_in_id', email: email));

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({'token': _token});
        await prefs.setString('userData', userData);

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

  Future<Map<String, dynamic>> registerWithEmailAndPassword(String name, String email, String password) async {
    // ...código de registro... (sem alterações)
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

  Future<void> signOut() async {
    // ...código de logout... (sem alterações)
    _token = null;
    _userController.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  // MÉTODO QUE ESTAVA FALTANDO
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

  // MÉTODO QUE ESTAVA FALTANDO
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

  void dispose() {
    _userController.close();
  }
}