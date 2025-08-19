// Arquivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'services/alarm_service.dart';
import 'utils/app_colors.dart';
import 'widgets/auth_wrapper.dart';

void main() {
  // Garante que os bindings do Flutter sejam inicializados antes de rodar o app.
  // Essencial para plugins como o Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VitaLogApp());
}

class VitaLogApp extends StatelessWidget {
  const VitaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider torna os serviços disponíveis para toda a árvore de widgets.
    return MultiProvider(
      providers: [
        // Para gerenciar o estado de autenticação e notificar os ouvintes.
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Fornece uma instância única do serviço de medicamentos.
        Provider<MedicationService>(create: (_) => MedicationService()),
        // Fornece uma instância única do serviço de alarme.
        Provider<AlarmService>(create: (_) => AlarmService()),
        // Expõe o stream de usuário para que o app reaja a logins/logouts.
        StreamProvider<UserModel?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'VitaLog',
        // Define o tema visual global do aplicativo.
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
        // O AuthWrapper decide qual tela mostrar (Login ou Home).
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
