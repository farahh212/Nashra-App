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
  String? imageUrl;
  Map<String, String> voterToOption = {};
   int ? commentsNo;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.endDate,
    Map<String, int>? votes,
    this.imageUrl,
    Map<String, String>? voterToOption,
    required this.commentsNo,
  })  : voterToOption = voterToOption ?? {},
        votes = votes ?? {},
        comments = [];

  Poll copyWith({Map<String, int>? votes,
    Map<String, String>? voterToOption,
    List<Comment>? comments,
    String? imageUrl,}) {
  return Poll(
    id: id,
    question: question,
    options: options,
    createdAt: createdAt,
    endDate: endDate,
    imageUrl: imageUrl ?? this.imageUrl,
    votes: votes ?? this.votes,
    voterToOption: voterToOption ?? this.voterToOption,
    commentsNo: commentsNo,
    

  );
}

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'votes': votes,
      'createdAt': createdAt.toIso8601String(),
      'endDate': endDate.toIso8601String(),
        'imageUrl': imageUrl,
        'commentsNo':commentsNo,
        
    };
  }

  factory Poll.fromMap(String id, Map<String, dynamic> map) {
    return Poll(
      id: id,
      question: map['question'],
      options: List<String>.from(map['options']),
    votes: Map<String, int>.from(map['votes'] ?? {}),
    voterToOption: Map<String, String>.from(map['voterToOption'] ?? {}),
    createdAt: DateTime.parse(map['createdAt']),
    endDate: DateTime.parse(map['endDate']),
    imageUrl: map['imageUrl'],
    commentsNo: map['coomentsNo']?? 0,
    );
  }
} 