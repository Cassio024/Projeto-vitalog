import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'services/alarm_service.dart';
import 'utils/app_colors.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/alarm_screen.dart'; // ⬅ importa seu AlarmScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();

  // 🔹 Solicitar permissão de notificações no navegador
  if (html.Notification.supported) {
    final permission = await html.Notification.requestPermission();
    print('Permissão de notificação: $permission');
  } else {
    print('Notificações não suportadas neste navegador.');
  }

  runApp(VitaLogApp(authService: authService));
}

class VitaLogApp extends StatelessWidget {
  final AuthService authService;
  const VitaLogApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<MedicationService>(create: (_) => MedicationService()),
        Provider<AlarmService>(create: (_) => AlarmService()),
        StreamProvider<UserModel?>(
          create: (_) => authService.user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'VitaLog',
        navigatorKey: navigatorKey,
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
        // 🔹 Agora temos rotas nomeadas
        routes: {
          '/': (context) => const AuthWrapper(),
          '/alarm': (context) => const AlarmScreen(), // rota do alarme
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
