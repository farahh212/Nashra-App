import 'package:flutter/foundation.dart';

class Report {
  String id;
  String title;
  String description;
  String? imageUrl;
  double latitude;
  double longitude;
  DateTime createdAt;
  bool read; // Added read property

  Report({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.read = false, // Default to false
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'read': read, // Add read to map
    };
  }

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      createdAt: DateTime.parse(map['createdAt']),
      read: map['read'] ?? false, // Read from map, default to false
    );
  }
}