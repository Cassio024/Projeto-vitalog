// ARQUIVO: lib/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Define o alinhamento e a cor da bolha com base em quem enviou
    final bool isUserMessage = message.sender == MessageSender.user;
    final alignment = isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUserMessage ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer;
    final textColor = isUserMessage ? Colors.white : Theme.of(context).colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              // Limita a largura máxima da bolha
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}