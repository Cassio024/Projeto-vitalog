// ARQUIVO: lib/models/medication_model.dart

class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> schedules;
  // Adicione outros campos que você possa ter, como 'user' ou 'date' se precisar deles no app
  
  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedules,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      // ESTA É A LINHA MAIS IMPORTANTE DA CORREÇÃO
      // Ela tenta ler o campo '_id' (padrão do MongoDB). Se não encontrar,
      // tenta ler o campo 'id'. Se não encontrar nenhum, usa uma string vazia
      // para evitar erros, mas o problema principal é garantir que um deles exista.
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      // Garante que 'schedules' seja sempre uma lista de strings, mesmo que venha nula
      schedules: List<String>.from(json['schedules'] ?? []),
    );
  }
}