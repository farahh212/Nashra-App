import 'package:flutter/foundation.dart';

enum AdvertisementStatus {
  pending,
  approved,
  rejected
}

class Advertisement {
  String id;
  String title;
  String description;
  String imageUrl;
  AdvertisementStatus status;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.status = AdvertisementStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last,
    };
  }

  factory Advertisement.fromMap(String id, Map<String, dynamic> map) {
    return Advertisement(
      id: id,
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      status: AdvertisementStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AdvertisementStatus.pending,
      ),
    );
  }
} 