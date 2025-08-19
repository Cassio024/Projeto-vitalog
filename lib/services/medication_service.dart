// Arquivo: lib/services/medication_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medication_model.dart';
import '../utils/constants.dart';

/// Serviço para gerenciar as operações de medicamentos com a API.
class MedicationService {
  /// Busca a lista de medicamentos de um usuário.
  Future<List<Medication>> getMedications(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Medication.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar medicamentos');
    }
  }

  /// Busca um medicamento específico pelo seu identificador de QR Code.
  Future<Medication> getMedicationByQRCode(String identifier, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications/qr/$identifier');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
    );

    if (response.statusCode == 200) {
      return Medication.fromJson(json.decode(response.body));
    } else {
      throw Exception('Medicamento não encontrado para este QR Code.');
    }
  }

  /// Adiciona um novo medicamento.
  Future<Map<String, dynamic>> addMedication(Map<String, dynamic> medicationData, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      body: json.encode(medicationData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao adicionar medicamento');
    }
  }

  /// Atualiza um medicamento existente.
  Future<void> updateMedication(String id, Map<String, dynamic> medicationData, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      body: json.encode(medicationData),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar medicamento');
    }
  }

  /// Deleta um medicamento.
  Future<void> deleteMedication(String id, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications/$id');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar medicamento');
    }
  }

  /// Busca o nome de um produto a partir do seu código de barras (GTIN).
  Future<String?> getMedicationNameFromBarcode(String gtin, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/barcode/$gtin');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['name'] as String?;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar nome do medicamento pelo código de barras: $e');
      return null;
    }
  }
}