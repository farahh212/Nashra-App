import 'package:flutter/foundation.dart';
import 'message.dart';

class Chat {
  String id;
  List<Message> messages;
  DateTime createdAt;

  Chat({
    required this.id,
    required this.createdAt,
  }) : messages = [];

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      id: id,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 