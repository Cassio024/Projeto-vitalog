// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/rasa_service.dart'; // <-- IMPORTA O NOSSO SERVIÇO
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
      text: 'Olá! Sou seu assistente virtual. Como posso ajudar com seus medicamentos hoje?',
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

  // --- ESTA FUNÇÃO FOI MODIFICADA PARA USAR A API REAL ---
  Future<void> _getBotResponse(String userMessage) async {
    // Chama a nossa função no rasa_service.dart para obter a resposta real
    final botResponses = await sendMessageToRasa(userMessage);

    // Adiciona cada resposta do bot à lista
    setState(() {
      for (var responseText in botResponses) {
        if (responseText.isNotEmpty) { // Garante que não adicionamos mensagens vazias
          _messages.insert(0, ChatMessage(text: responseText, sender: MessageSender.bot));
        }
      }
      _isBotTyping = false; // Esconde o indicador "digitando..."
    });

    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Virtual'),
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2.0),
                  SizedBox(width: 8.0),
                  Text('Assistente digitando...'),
                ],
              ),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
          )
        ]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Digite sua mensagem...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}
