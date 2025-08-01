// Arquivo: lib/models/medication_model.dart
// (Sem alterações)
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
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      schedules: List<String>.from(json['schedules']),
    );
  }
}