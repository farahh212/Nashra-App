import 'package:flutter/foundation.dart';

class Notification {
  String id;
  String title;
  String description;
  DateTime createdAt;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory Notification.fromMap(String id, Map<String, dynamic> map) {
    return Notification(
      id: id,
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }
} 