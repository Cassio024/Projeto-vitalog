// Arquivo: lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService with ChangeNotifier {
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get user => _userController.stream;
  String? _token;

  String? get token => _token;

  Future<Map<String, dynamic>> _handleAuthRequest(String endpoint, Map<String, String> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['token'] != null) {
          _token = responseData['token'];
          Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
          final user = UserModel(
            uid: decodedToken['user']['id'],
            name: decodedToken['user']['name'],
            email: body['email'],
          );
          _userController.add(user);
          notifyListeners();
        }
        return {'success': true, 'message': responseData['msg']};
      } else {
        return {'success': false, 'message': responseData['msg'] ?? 'Ocorreu um erro'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Não foi possível conectar ao servidor.'};
    }
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    return await _handleAuthRequest('login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> registerWithEmailAndPassword(String name, String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/register');
     try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      final responseData = json.decode(response.body);
       if (response.statusCode < 300) {
         return {'success': true};
       }
       return {'success': false, 'message': responseData['msg'] ?? 'Erro desconhecido'};
     } catch(e) {
       return {'success': false, 'message': 'Não foi possível conectar ao servidor.'};
     }
  }

  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    return await _handleAuthRequest('forgot-password', {'email': email});
  }

  Future<Map<String, dynamic>> resetPassword(String email, String code, String password) async {
    return await _handleAuthRequest('reset-password', {'email': email, 'code': code, 'password': password});
  }

  Future<void> signOut() async {
    _token = null;
    _userController.add(null);
    notifyListeners();
  }
}

