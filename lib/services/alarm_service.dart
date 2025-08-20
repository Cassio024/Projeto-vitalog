// Arquivo: lib/service/alarm_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Defina essa chave em um local global (ex: main.dart) e use no MaterialApp:
final navigatorKey = GlobalKey<NavigatorState>();

class AlarmService {
  final Map<String, Timer> _medicationTimers = {};

  Future<bool> _garantirPermissaoNotificacao() async {
    if (!kIsWeb) return false;

    if (!html.Notification.supported) {
      debugPrint("❌ Notificações não suportadas neste navegador");
      return false;
    }

    if (html.Notification.permission == 'granted') return true;

    if (html.Notification.permission == 'denied') {
      debugPrint("🚫 Usuário negou notificações");
      return false;
    }

    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  void generateAlarms({
    required String medicationId,
    required String medicationName,
    required DateTime startTime,
    required Duration interval,
    required int count,
  }) async {
    final permitido = await _garantirPermissaoNotificacao();
    if (!permitido) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Ative as notificações para receber os alertas'),
          ),
        );
      }
      return;
    }

    final now = DateTime.now();
    final alarms = <DateTime>[];

    for (int i = 0; i < count; i++) {
      final alarmTime = startTime.add(interval * i);
      if (alarmTime.isAfter(now)) {
        alarms.add(alarmTime);
      }
    }

    _scheduleNextAlarm(medicationId, medicationName, alarms);
  }

  void _scheduleNextAlarm(
    String medicationId,
    String medicationName,
    List<DateTime> alarms,
  ) {
    if (alarms.isEmpty) return;

    final now = DateTime.now();
    final nextAlarm = alarms.firstWhere(
      (alarm) => alarm.isAfter(now),
      orElse: () => alarms.first,
    );

    final delay = nextAlarm.difference(now);

    _medicationTimers[medicationId]?.cancel();

    _medicationTimers[medicationId] = Timer(delay, () {
      _triggerAlarm('Hora do remédio!', 'Tome o medicamento: $medicationName');
      alarms.remove(nextAlarm);
      _scheduleNextAlarm(medicationId, medicationName, alarms);
    });
  }

  /// Método PRIVADO original — contém toda a lógica de áudio/vibração/modal
  void _triggerAlarm(String title, String body) {
    if (!kIsWeb) return;

    final audio = html.AudioElement()
      ..src = 'assets/alarm.mp3'
      ..loop = true
      ..preload = 'auto';

    audio.play().catchError((err) {
      debugPrint('⚠️ Erro ao reproduzir áudio: $err');
    });

    js_util.callMethod(html.window.navigator, 'vibrate', [
      [300, 200, 300, 200, 300],
    ]);

    if (html.Notification.supported &&
        html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }

    if (html.document.visibilityState == 'visible') {
      final ctx = navigatorKey.currentState?.overlay?.context;
      if (ctx != null) {
        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () {
                  audio.pause();
                  audio.src = '';
                  Navigator.of(ctx).pop();
                },
                child: const Text('Desligar'),
              ),
              TextButton(
                onPressed: () {
                  audio.pause();
                  audio.src = '';
                  Navigator.of(ctx).pop();
                  // implementar soneca aqui
                },
                child: const Text('Soneca'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Novo método PÚBLICO para disparar o alarme manualmente
  void triggerAlarmNow(String title, String body) {
    _triggerAlarm(title, body);
  }

  void cancelAlarmsForMedication(String medicationId) {
    _medicationTimers[medicationId]?.cancel();
    _medicationTimers.remove(medicationId);
    debugPrint("⏹ Alarmes do medicamento $medicationId cancelados");
  }

  void cancelAllAlarms() {
    for (var timer in _medicationTimers.values) {
      timer.cancel();
    }
    _medicationTimers.clear();
    debugPrint("⏹ Todos os alarmes cancelados");
  }

  void showNotification(String title, String body) {
    if (!kIsWeb) return;

    if (html.Notification.supported &&
        html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  }
}
