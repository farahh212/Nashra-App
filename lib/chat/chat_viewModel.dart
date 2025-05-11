import 'package:flutter/material.dart';
import 'message_model.dart';
import 'chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Future<void> sendMessage(String chatId, String text, String senderId) {
    final message = Message(
      id: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );
    return _chatService.sendMessage(chatId, message);
  }
}