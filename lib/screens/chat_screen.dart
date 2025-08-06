// ARQUIVO: lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../widgets/message_bubble.dart';
// Importe o serviço Rasa
import '../services/rasa_service.dart'; // Adicionado: Importa o arquivo de serviço do Rasa

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
    // Adiciona uma mensagem inicial do bot
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
  
  // Função chamada quando o usuário envia uma mensagem
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();

    // Adiciona a mensagem do usuário à lista
    setState(() {
      _messages.insert(0, ChatMessage(text: text, sender: MessageSender.user));
      _isBotTyping = true; // Mostra o indicador "digitando..."
    });

    // Anima a lista para a nova mensagem
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    
    // Pega a resposta do Bot
    _getBotResponse(text);
  }

  // AQUI É ONDE SEU AMIGO VAI TRABALHAR
  Future<void> _getBotResponse(String userMessage) async {
    // =======================================================================
    // MODIFICADO: Chamada real à API do Rasa
    // Substitua a simulação de atraso e o texto fixo pela chamada ao seu serviço Rasa.
    try {
      final List<String> botResponses = await sendMessageToRasa(userMessage);
      
      // Itera sobre as respostas do bot (Rasa pode retornar múltiplas mensagens)
      for (String botText in botResponses) {
        setState(() {
          _messages.insert(0, ChatMessage(text: botText, sender: MessageSender.bot));
        });
      }
    } catch (e) {
      // Em caso de erro na comunicação com o Rasa
      setState(() {
        _messages.insert(0, ChatMessage(text: 'Desculpe, não foi possível conectar ao assistente. Erro: $e', sender: MessageSender.bot));
      });
    } finally {
      setState(() {
        _isBotTyping = false; // Esconde o indicador "digitando..."
      });
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    // =======================================================================
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
              reverse: true, // Faz a lista começar de baixo para cima
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

  // Widget para o campo de texto e botão de enviar
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
