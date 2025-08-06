// lib/services/rasa_service.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Esta função envia uma mensagem para o servidor Rasa e recebe a resposta.
Future<List<String>> sendMessageToRasa(String message) async {
  // --------------------------------------------------------------------------
  // ATENÇÃO: VOCÊ DEVE ATUALIZAR ESTA URL AQUI!
  // Copie a URL da linha "Forwarding" do seu terminal ngrok (ex: 'https://sua-url.ngrok-free.app').
  // IMPORTANTE: Esta URL muda cada vez que você inicia o ngrok na versão gratuita!
  // --------------------------------------------------------------------------
  const String ngrokEndpoint = 'https://5eb5c4be188e.ngrok-free.app'; // <--- MUDAR AQUI!

  // Lógica para escolher o endereço da API
  // Se a URL do ngrok estiver definida, use-a. Caso contrário, use a lógica local.
  final String rasaEndpoint;

  if (ngrokEndpoint.isNotEmpty) {
    rasaEndpoint = '$ngrokEndpoint/webhooks/rest/webhook';
  } else {
    // Se for web (PC), usa localhost. Se for mobile, usa o endereço especial do emulador.
    rasaEndpoint = kIsWeb
        ? 'http://localhost:5005/webhooks/rest/webhook'
        : 'http://10.0.2.2:5005/webhooks/rest/webhook';
  }

  try {
    final response = await http.post(
      Uri.parse(rasaEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender': 'flutter_user', // Um ID para identificar o utilizador
        'message': message,      // A mensagem que o utilizador digitou
      }),
    );

    if (response.statusCode == 200) {
      // Usamos utf8.decode para garantir que acentos e caracteres especiais funcionem
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));

      if (responseData.isEmpty) {
        return ["Desculpe, não obtive uma resposta. Tente novamente."];
      }

      // Extrai as mensagens de texto da resposta do bot
      final List<String> botMessages = responseData
          .map((item) => item['text'] as String? ?? '') // Previne erros se o texto for nulo
          .toList();

      return botMessages;
    } else {
      print('Erro do servidor Rasa: ${response.statusCode}');
      return ['Desculpe, ocorreu um erro ao comunicar com o assistente.'];
    }
  } catch (e) {
    print('Erro de conexão com o Rasa: $e');
    return ['Não foi possível conectar ao nosso assistente. Por favor, tente mais tarde.'];
  }
}
