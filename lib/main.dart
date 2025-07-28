// Arquivo: lib/main.dart
// CORRIGIDO: Garante que uma única instância do AuthService seja usada em todo o app.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';
import 'widgets/auth_wrapper.dart';

void main() {
  runApp(const VitaLogApp());
}

class VitaLogApp extends StatelessWidget {
  const VitaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos um MultiProvider para fornecer múltiplos serviços.
    return MultiProvider(
      providers: [
        // 1. Fornece uma ÚNICA instância de AuthService para todo o app.
        Provider<AuthService>(create: (_) => AuthService()),
        // 2. O StreamProvider agora usa a instância criada acima para ouvir o stream do usuário.
        StreamProvider<UserModel?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'VitaLog',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(), // O AuthWrapper agora é a tela inicial
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}