import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'message.dart';

class Chat {
  String id;
  List<Message> messages;
  DateTime createdAt;
  String name;
  String userEmail1;
  String userEmail2;

  Chat({
    required this.name,
    required this.id,
    required this.createdAt,
    required this.userEmail1,
    required this.userEmail2,
  }) : messages = [];

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map, String id,String name) {
    final timestamp = map['createdAt'];
   final createdAt = timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp);
    return Chat(
      name: name,
      id: id,
      createdAt: createdAt,
      userEmail1: map['userEmail1'] ?? '',
      userEmail2: map['userEmail2'] ?? '',
    );
  }
} 