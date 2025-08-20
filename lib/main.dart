import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'services/alarm_service.dart';
import 'utils/app_colors.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/alarm_screen.dart'; // Importa a tela de alarme

// A GlobalKey para o Navigator pode ser útil para navegação sem o context.
// Se não estiver usando, pode ser removida.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Garante que os bindings do Flutter sejam inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  // Instancia o serviço de autenticação uma única vez.
  final authService = AuthService();

  // Solicita permissão de notificações no navegador (para web).
  if (html.Notification.supported) {
    final permission = await html.Notification.requestPermission();
    print('Permissão de notificação: $permission');
  } else {
    print('Notificações não são suportadas neste navegador.');
  }

  runApp(VitaLogApp(authService: authService));
}

class VitaLogApp extends StatelessWidget {
  final AuthService authService;
  const VitaLogApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // MultiProvider torna os serviços disponíveis para toda a árvore de widgets.
    return MultiProvider(
      providers: [
        // Fornece a instância já criada do AuthService.
        ChangeNotifierProvider<AuthService>.value(value: authService),
        // Cria e fornece uma instância única do serviço de medicamentos.
        Provider<MedicationService>(create: (_) => MedicationService()),
        // Cria e fornece uma instância única do serviço de alarme.
        Provider<AlarmService>(create: (_) => AlarmService()),
        // Expõe o stream de usuário para que o app reaja a mudanças de autenticação.
        StreamProvider<UserModel?>(
          create: (_) => authService.user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'VitaLog',
        navigatorKey: navigatorKey, // Chave para navegação global.
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
        // Define as rotas nomeadas da aplicação.
        routes: {
          // A rota inicial '/' aponta para o AuthWrapper, que decide qual tela mostrar.
          '/': (context) => const AuthWrapper(),
          '/alarm': (context) => const AlarmScreen(), // Rota para a tela de alarme.
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
