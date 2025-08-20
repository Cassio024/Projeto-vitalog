import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/alarm_service.dart'; // ajuste o path se necessário

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool _autoplayBlocked = false;

  @override
  void initState() {
    super.initState();

    // Tenta disparar o alarme imediatamente, mas só se logado
    Future.microtask(() {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.isLoggedIn()) {
        try {
          AlarmService().triggerAlarmNow(
            'Hora do remédio!',
            'Tome o medicamento agora',
          );
        } catch (e) {
          debugPrint('⚠️ Alarme bloqueado por autoplay: $e');
          setState(() {
            _autoplayBlocked = true;
          });
        }
      } else {
        debugPrint('Usuário não loggado — alarme não será tocado');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm, size: 100, color: Colors.red[400]),
            const SizedBox(height: 20),
            const Text(
              'Hora do remédio!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tome seu medicamento agora.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            // Se o autoplay for bloqueado e estiver logado, mostra botão para tocar manualmente
            _autoplayBlocked && authService.isLoggedIn()
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      AlarmService().triggerAlarmNow(
                        'Hora do remédio!',
                        'Tome o medicamento agora',
                      );
                      setState(() => _autoplayBlocked = false);
                    },
                    child: const Text(
                      'Tocar Alarme',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Desligar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
