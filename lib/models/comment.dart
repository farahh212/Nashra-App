import 'package:flutter/foundation.dart';

class Comment {
  String id;
  String userId;
  String? name;
  String content;
  bool anonymous;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
     this.name,
    required this.content,
    this.anonymous = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'name': name,
      'anonymous': anonymous,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      userId: map['userId'],
      name: map['name'],

      content: map['content'],
      anonymous: map['anonymous'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 