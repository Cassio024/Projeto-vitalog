// Arquivo: lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService with ChangeNotifier {
  final StreamController<UserModel?> _userController =
      StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get user => _userController.stream;
  String? _token;

  String? get token => _token;

  Future<Map<String, dynamic>> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
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
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Erro desconhecido',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
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
        Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
        final user = UserModel(uid: decodedToken['user']['id'], email: email);
        _userController.add(user);
        notifyListeners();
        return {'success': true};
      } else {
        _userController.add(null);
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Credenciais inválidas',
        };
      }
    } catch (error) {
      _userController.add(null);
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor.',
      };
    }
  }

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
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Erro ao enviar email.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String password,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code, 'password': password}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['msg']};
      } else {
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Erro ao redefinir senha.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  Future<void> signOut() async {
    _token = null;
    _userController.add(null);
    notifyListeners();
  }
}
