import 'package:flutter/foundation.dart';

enum AdvertisementStatus {
  pending,
  approved,
  rejected,
}

class Advertisement {
  String id;
  String title;
  String description;
  String? imageUrl; // ✅ Optional: set after image is uploaded
  AdvertisementStatus status;
  String ownerId;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl, // ✅ now optional
    this.status = AdvertisementStatus.pending,
    required this.ownerId,
  });

  /// Convert the ad to a map for Firebase
  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'ownerId': ownerId,
    };
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl!;
    }
    return map;
  }

  /// Convert a Firebase map to an Advertisement object
  factory Advertisement.fromMap(String id, Map<String, dynamic> map) {
    return Advertisement(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
       ownerId: map['ownerId'] ?? '',
      imageUrl: map['imageUrl'], // ✅ can be null
      status: AdvertisementStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AdvertisementStatus.pending,
      ),
    );
  }
}
