import 'package:cloud_firestore/cloud_firestore.dart';
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
    final timestamp = map['createdAt'];
   final createdAt = timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp);
    return Message(
      id: id,
      senderId: map['senderId'],
      content: map['content'],
      createdAt: createdAt,
      chatId: map['chatId'],
    );
  }
} 