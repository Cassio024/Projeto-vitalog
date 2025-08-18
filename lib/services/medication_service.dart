// Arquivo: lib/services/medication_service.dart
import 'dart:convert';
import 'dart:io'; // Importado para HttpStatus
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/medication_model.dart';

class MedicationService {
  // MELHORIA: Função privada para criar os headers, evitando repetição de código.
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-auth-token': token,
    };
  }

  Future<List<Medication>> getMedications(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications');
    try {
      final response = await http.get(url, headers: _getHeaders(token));

      // MELHORIA: Lança um erro se a requisição falhar.
      if (response.statusCode != HttpStatus.ok) {
        // HttpStatus.ok == 200
        throw Exception(
          'Falha ao carregar os medicamentos: ${response.statusCode}',
        );
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Medication.fromJson(json)).toList();
    } catch (e) {
      // Re-lança a exceção para que a UI possa tratá-la.
      throw Exception('Erro de conexão ao buscar medicamentos: $e');
    }
  }

  Future<Map<String, dynamic>> addMedication(
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: json.encode(data),
      );

      if (response.statusCode != HttpStatus.created &&
          response.statusCode != HttpStatus.ok) {
        throw Exception(
          'Falha ao adicionar medicamento: ${response.statusCode}',
        );
      }
      print(response);
      return json.decode(response.body); // ✅ retorna o JSON com 'id'
    } catch (e) {
      throw Exception('Erro de conexão ao adicionar medicamento: $e');
    }
  }

  Future<void> updateMedication(
    String medId,
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications/$medId');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(token),
        body: json.encode(data),
      );

      // CORREÇÃO: Verifica se a atualização foi bem-sucedida (200 OK)
      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          'Falha ao atualizar medicamento: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro de conexão ao atualizar medicamento: $e');
    }
  }

  Future<void> deleteMedication(String medId, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/medications/$medId');
    try {
      final response = await http.delete(url, headers: _getHeaders(token));

      // CORREÇÃO: Verifica se a deleção foi bem-sucedida (200 OK ou 204 No Content)
      if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.noContent) {
        throw Exception('Falha ao deletar medicamento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao deletar medicamento: $e');
    }
  }

  // Os métodos abaixo já tinham try/catch, mas vamos padronizar para lançar exceções.
  Future<Map<String, dynamic>> checkInteractions(
    List<String> medicationNames,
    String token,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/interactions/check');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: json.encode({'medicationNames': medicationNames}),
      );

      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          'Falha ao verificar interações: ${response.statusCode}',
        );
      }
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erro de conexão ao verificar interações: $e');
    }
  }

  Future<Map<String, dynamic>> verifyAuthenticity(
    String qrCodeId,
    String token,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/drugs/verify/$qrCodeId');
    try {
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          'Falha ao verificar autenticidade: ${response.statusCode}',
        );
      }
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erro de conexão ao verificar autenticidade: $e');
    }
  }
}
