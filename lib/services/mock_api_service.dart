// Arquivo: lib/services/mock_api_service.dart
// (Sem alterações)
import '../models/medication_model.dart';

class MockApiService {
  Future<List<Medication>> getMedications() async {
    await Future.delayed(const Duration(seconds: 1));
    final mockData = [
      {
        'id': '1',
        'name': 'Paracetamol 750mg',
        'dosage': '1 comprimido',
        'schedules': ['08:00', '20:00'],
      },
      {
        'id': '2',
        'name': 'Losartana 50mg',
        'dosage': '1 comprimido',
        'schedules': ['09:00'],
      },
      {
        'id': '3',
        'name': 'Vitamina D 2000UI',
        'dosage': '2 cápsulas',
        'schedules': ['12:00'],
      },
       {
        'id': '4',
        'name': 'Amoxicilina 500mg',
        'dosage': '1 comprimido',
        'schedules': ['07:00', '15:00', '23:00'],
      },
    ];
    return mockData.map((json) => Medication.fromJson(json)).toList();
  }
}
