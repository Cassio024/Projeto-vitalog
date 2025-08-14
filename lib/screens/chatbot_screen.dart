import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/chat_message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.insert(0, ChatMessage(
      text: 'Olá! Sou o assistente virtual VitaLog. Como posso ajudar?',
      sender: MessageSender.bot,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.insert(0, ChatMessage(text: text, sender: MessageSender.user));
      _isBotTyping = true;
    });

    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _getBotResponse(text);
  }

  // VERSÃO ATUALIZADA PARA O NOVO ENDPOINT /ask
  Future<void> _getBotResponse(String userMessage) async {
    // URL atualizada para o novo endpoint /ask
    const String chatApiUrl = 'https://vitalog-api-nova.onrender.com/ask';
    String botText = "Desculpe, ocorreu um erro. Tente novamente.";

    try {
      final response = await http.post(
        Uri.parse(chatApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': userMessage,
          'conversationHistory': [] // Pode adicionar histórico depois se quiser
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          botText = data['data']['response'];
        } else {
          botText = data['error'] ?? 'Resposta inválida da API';
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        botText = data['error'] ?? 'Mensagem inválida. Tente reformular sua pergunta.';
      } else if (response.statusCode == 429) {
        botText = 'Muitas requisições. Aguarde um momento e tente novamente.';
      } else if (response.statusCode == 503) {
        botText = 'Serviço temporariamente indisponível. Tente novamente em alguns minutos.';
      } else {
        botText = 'O assistente está indisponível no momento. Tente mais tarde.';
        print('Erro na API do chatbot: ${response.statusCode} | ${response.body}');
      }
    } catch (e) {
      botText = 'Erro de conexão. Verifique sua internet.';
      print('Erro de conexão com o chatbot: $e');
    }

    // Adiciona a resposta à lista
    setState(() {
      _messages.insert(0, ChatMessage(text: botText, sender: MessageSender.bot));
      _isBotTyping = false;
    });

    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Virtual VitaLog'),
        backgroundColor: Colors.teal,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isBotTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                  const SizedBox(width: 12.0),
                  const Text('VitaLog está a pensar...'),
                ],
              ),
            ),
          _buildInputComposer(),
        ],
      ),
    );
  }

  Widget _buildInputComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 4, color: Colors.black.withOpacity(0.08))]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Pergunte sobre um medicamento...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}