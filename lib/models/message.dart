import 'package:flutter/foundation.dart';

class Message {
  String id;
  String senderId;
  String content;
  DateTime createdAt;
  String chatId;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.chatId,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'chatId': chatId,
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      senderId: map['senderId'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      chatId: map['chatId'],
    );
  }
} 