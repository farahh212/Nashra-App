import 'package:flutter/foundation.dart';
import 'comment.dart';

class Poll {
  String id;
  String question;
  List<String> options;
  Map<String, int> votes;
  DateTime createdAt;
  DateTime endDate;
  List<Comment> comments;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.endDate,
    Map<String, int>? votes,
  }) : votes = votes ?? {}, comments = [];

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'votes': votes,
      'createdAt': createdAt.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Poll.fromMap(String id, Map<String, dynamic> map) {
    return Poll(
      id: id,
      question: map['question'],
      options: List<String>.from(map['options']),
      // votes: Map<String, int>.from(map['votes'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      endDate: DateTime.parse(map['endDate']),
    );
  }
} 