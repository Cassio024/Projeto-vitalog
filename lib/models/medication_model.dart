// Arquivo: lib/models/medication_model.dart
import 'package:flutter/foundation.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> schedules;
  final DateTime? expirationDate;
  final String? qrCodeIdentifier;
  // CAMPO ADICIONADO: Mapa para guardar o estado de cada dose.
  final Map<String, bool> dosesTaken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedules,
    this.expirationDate,
    this.qrCodeIdentifier,
    // PARÂMETRO ADICIONADO: Para inicializar o mapa de doses
    Map<String, bool>? dosesTaken,
  }) : dosesTaken = dosesTaken ?? {}; // Garante que o mapa nunca seja nulo

  // Lógica de verificação de validade (mantida como você enviou)
  bool get isExpired {
    if (expirationDate == null) return false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return expirationDate!.isBefore(today);
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    // LÓGICA ADICIONADA: Para converter o mapa de doses do JSON
    final dosesTakenMap = (json['dosesTaken'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as bool),
        ) ??
        {};

    return Medication(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Nome não encontrado',
      dosage: json['dosage'] as String? ?? 'Dosagem não informada',
      schedules: List<String>.from(json['schedules'] ?? []),
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'])
          : null,
      qrCodeIdentifier: json['qrCodeIdentifier'] as String?,
      // CAMPO ADICIONADO: Passando o mapa de doses para o construtor
      dosesTaken: dosesTakenMap,
    );
  }

  // FUNÇÃO ADICIONADA: Para consistência e futuras atualizações
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'schedules': schedules,
      'expirationDate': expirationDate?.toIso8601String(),
      'qrCodeIdentifier': qrCodeIdentifier,
      'dosesTaken': dosesTaken,
    };
  }
}
