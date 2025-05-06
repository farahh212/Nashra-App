import 'package:flutter/foundation.dart';
import 'comment.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime date;
  String location;
  List<String> attendees;
  List<Comment> comments;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  }) : attendees = [], comments = [];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'attendees': attendees,
    };
  }

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      attendees: List<String>.from(map['attendees'] ?? []),
    );
  }
} 