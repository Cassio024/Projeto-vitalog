// Arquivo: lib/models/medication_model.dart
// Nenhuma alteração grande aqui, apenas garantindo que a lógica 'isExpired' está correta.
class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> schedules;
  final DateTime? expirationDate;
  final String? qrCodeIdentifier;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedules,
    this.expirationDate,
    this.qrCodeIdentifier,
  });

  // ✅ LÓGICA DE VERIFICAÇÃO DE VALIDADE
  // Retorna 'true' se a data de validade for anterior ao dia de hoje.
  bool get isExpired {
    if (expirationDate == null) return false;
    // Compara a data de validade com o início do dia de hoje para ser preciso.
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return expirationDate!.isBefore(today);
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Nome não encontrado',
      dosage: json['dosage'] as String? ?? 'Dosagem não informada',
      schedules: List<String>.from(json['schedules'] ?? []),
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'])
          : null,
      qrCodeIdentifier: json['qrCodeIdentifier'] as String?,
    );
  }
}
