// NOVO ARQUIVO: lib/widgets/auth_wrapper.dart
// Este widget decide qual tela mostrar: Login ou Home, com base no estado de auth.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Se o usuário for nulo, mostra a tela de login.
    if (user == null) {
      return const LoginScreen();
    } else {
      // Se houver um usuário, vai para a tela principal.
      return const HomeScreen();
    }
  }
}
