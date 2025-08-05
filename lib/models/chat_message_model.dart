// ARQUIVO: lib/models/chat_message_model.dart

// Enum para identificar quem enviou a mensagem
enum MessageSender { user, bot }

class ChatMessage {
  final String text;
  final MessageSender sender;

  ChatMessage({
    required this.text,
    required this.sender,
  });
}