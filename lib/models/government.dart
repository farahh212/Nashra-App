import 'package:flutter/foundation.dart';
import 'announcement.dart';
import 'poll.dart';
import 'chat.dart';
import 'emergency_number.dart';
import 'notification.dart';

class Government {
  String id;
  String name;
  String email;
  String password;
  List<Announcement> announcements;
  List<Poll> polls;
  List<Chat> chats;
  List<EmergencyNumber> numbers;
  List<Notification> notifications;

  Government({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  })  : announcements = [],
        polls = [],
        chats = [],
        numbers = [],
        notifications = [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory Government.fromMap(String id, Map<String, dynamic> map) {
    return Government(
      id: id,
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
} 