import 'package:flutter/foundation.dart';

class EmergencyNumber {
  String id;
  int number;
  String title;

  EmergencyNumber({
    required this.id,
    required this.number,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'title': title,
    };
  }

  factory EmergencyNumber.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyNumber(
      id: id,
      number: map['number'],
      title: map['title'],
    );
  }
} 