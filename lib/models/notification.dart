import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String id;
  String title;
  String description;
  DateTime createdAt;
  bool isRead;
  String userEmail;

  Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.userEmail,
    
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'userEmail': userEmail,
    };
  }

  factory Notification.fromMap(String id, Map<String, dynamic> map) {
    return Notification(
      id: id,
      title: map['title'],
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      userEmail: map['userEmail'] ?? '',
    );
  }
} 