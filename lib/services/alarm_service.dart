import 'dart:async';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AlarmService {
  // Agora guardamos timers por ID de medicamento como String
  final Map<String, Timer> _medicationTimers = {};

  /// Gera os alarmes para um medicamento específico
  void generateAlarms({
    required String medicationId,
    required String medicationName, // 🆕 novo parâmetro
    required DateTime startTime,
    required Duration interval,
    required int count,
  }) {
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

  /// Agenda o próximo alarme e continua a sequência
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
      showNotification(
        'Hora do remédio!',
        'Tome o medicamento: $medicationName',
      );
      alarms.remove(nextAlarm);
      _scheduleNextAlarm(medicationId, medicationName, alarms);
    });
  }

  /// Cancela alarmes apenas de um medicamento
  void cancelAlarmsForMedication(String medicationId) {
    _medicationTimers[medicationId]?.cancel();
    _medicationTimers.remove(medicationId);
    debugPrint("⏹ Alarmes do medicamento $medicationId cancelados");
  }

  /// Cancela todos os alarmes de todos os medicamentos
  void cancelAllAlarms() {
    for (var timer in _medicationTimers.values) {
      timer.cancel();
    }
    _medicationTimers.clear();
    debugPrint("⏹ Todos os alarmes cancelados");
  }

  /// Mostra notificação (Flutter Web)
  void showNotification(String title, String body) {
    if (!kIsWeb) return;

    if (html.Notification.supported) {
      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
      } else {
        html.Notification.requestPermission().then((permission) {
          if (permission == 'granted') {
            html.Notification(title, body: body);
          }
        });
      }
    }
  }
}
