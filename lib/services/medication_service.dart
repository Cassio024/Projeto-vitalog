// lib/services/medication_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_model.dart';
import '../utils/constants.dart';

class MedicationService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return null;
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    return extractedUserData['token'];
  }

  Future<List<Medication>> getMedications() async {
    // ... (código existente, sem alterações)
    final token = await _getToken();
    if (token == null) throw Exception('Não autorizado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'x-auth-token': token,
    });

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Medication.fromJson(data)).toList();
    } else {
      throw Exception('Falha ao carregar medicamentos');
    }
  }

  // MODIFICAÇÃO: A função agora retorna o mapa completo da resposta da API.
  Future<Map<String, dynamic>> addMedication(String name, String dosage, List<String> schedules) async {
    final token = await _getToken();
    if (token == null) throw Exception('Não autorizado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({
        'name': name,
        'dosage': dosage,
        'schedules': schedules,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // MODIFICAÇÃO: Retorna o JSON decodificado diretamente.
      // Ele conterá {"medication": {...}, "warning": "..."}
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao adicionar medicamento.');
    }
  }
  
  Future<Map<String, dynamic>> deleteMedication(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Não autorizado. Faça login novamente.'};
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/medications/$id');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Medicamento removido com sucesso.'};
      } else {
        return {'success': false, 'message': 'Falha ao remover medicamento. Tente novamente.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: ${e.toString()}'};
    }
  }
}