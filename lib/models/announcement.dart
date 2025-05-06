import 'package:flutter/foundation.dart';
import 'comment.dart';

class Announcement {
  String id;
  String title;
  String description;
  String? imageUrl;
  String? fileUrl;
  DateTime createdAt;
  List<Comment> comments;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.fileUrl,
    required this.createdAt,
  }) : comments = [];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      fileUrl: map['fileUrl'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 