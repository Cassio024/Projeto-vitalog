import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class DrugService {
  Future<Map<String, dynamic>> verifyDrug(String qrCodeId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/drugs/verify/$qrCodeId');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      final responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      return {
        'authentic': false,
        'message': 'Erro de conexão. Verifique a internet e tente novamente.'
      };
    }
  }
}