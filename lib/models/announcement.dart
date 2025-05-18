import 'package:flutter/foundation.dart';
import 'package:nashra_project2/models/citizen.dart';
import 'comment.dart';

class Announcement {
  String id;
  String title;
  String description;
  String? imageUrl;
  String? fileUrl;
  DateTime createdAt;
  int likes;
  int ? commentsNo;
  List<Comment> comments;
  List<String> likedByUser =[];
  // List<Citizen> likedByUser;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.fileUrl,
    required this.createdAt,
   required this.likes,
   required this.likedByUser,
    required this.commentsNo,
   
    
  }) : comments = [];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
      'commentsNo':commentsNo,
      'likedByUser': likedByUser,

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
      likes: map['likes'] ?? 0,
      commentsNo: map['coomentsNo']?? 0,
      likedByUser: List<String>.from(map['likedByUser'] ?? []),
    );
  }
} 