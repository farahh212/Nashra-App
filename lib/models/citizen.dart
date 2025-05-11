import 'package:flutter/foundation.dart';
import 'advertisement.dart';
import 'notificatin.dart';
import 'report.dart';

class Citizen {
  String id;
  String name;
  String email;
  String password;
  List<Advertisement> ads;
  List<Notification> notifications;
  List<Report> reports;

  Citizen({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  })  : ads = [],
        notifications = [],
        reports = [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory Citizen.fromMap(String id, Map<String, dynamic> map) {
    return Citizen(
      id: id,
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
} 