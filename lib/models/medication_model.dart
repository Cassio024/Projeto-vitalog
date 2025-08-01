// Arquivo: lib/models/medication_model.dart
// MODIFICADO: Agora usa o `_id` do MongoDB.
import 'package:intl/intl.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> schedules;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedules,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['_id'], // O MongoDB usa '_id' por padrão
      name: json['name'],
      dosage: json['dosage'],
      schedules: List<String>.from(json['schedules']),
    );
  }
}