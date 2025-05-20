import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/advertisement.dart';

class AdvertisementProvider with ChangeNotifier {
  List<Advertisement> _advertisements = [];

  List<Advertisement> get advertisements => [..._advertisements];

  // ✅ Create a new advertisement
  Future<void> addAdvertisement(Advertisement advertisement, String token) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': advertisement.title,
            'description': advertisement.description,
            'imageUrl': advertisement.imageUrl,
            'status': advertisement.status.toString().split('.').last,
            'ownerId': advertisement.ownerId,
          }));

      final newAd = Advertisement(
        id: json.decode(response.body)['name'],
        title: advertisement.title,
        description: advertisement.description,
        imageUrl: advertisement.imageUrl,
        status: advertisement.status,
        ownerId: advertisement.ownerId,
      );
      _advertisements.add(newAd);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // ✅ Fetch all advertisements
  Future<void> fetchAdvertisements(String token) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      if (extractedData == null) return;

      final List<Advertisement> loadedAds = [];
      extractedData.forEach((adId, adData) {
        loadedAds.add(Advertisement.fromMap(adId, adData));
      });

      _advertisements = loadedAds;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // ✅ Get advertisements by owner (user)
  Future<List<Advertisement>> getUserAdvertisements(String token, String userId) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');

    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) return [];

    final List<Advertisement> userAds = [];
    extractedData.forEach((adId, adData) {
      if (adData['ownerId'] == userId) {
        userAds.add(Advertisement.fromMap(adId, adData));
      }
    });
    return userAds;
  }

  // ✅ Get advertisement by ID
  Future<Advertisement?> getAdvertisementById(String id, String token) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');

    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null || !extractedData.containsKey(id)) return null;

    final adData = extractedData[id];
    return Advertisement.fromMap(id, adData);
  }

  // ✅ Update advertisement
Future<void> updateAdvertisement(String id, Advertisement updatedAd, String token) async {
  final url = Uri.parse(
      'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB/$id.json?auth=$token');

  try {
    await http.patch(url,
        body: json.encode({
          'title': updatedAd.title,
          'description': updatedAd.description,
          'imageUrl': updatedAd.imageUrl,
          'status': 'pending', // ✅ Always reset status to pending
        }));

    final index = _advertisements.indexWhere((ad) => ad.id == id);
    if (index >= 0) {
      _advertisements[index] = Advertisement(
        id: updatedAd.id,
        title: updatedAd.title,
        description: updatedAd.description,
        imageUrl: updatedAd.imageUrl,
        status: AdvertisementStatus.pending, // ✅ Ensure local state is also pending
        ownerId: updatedAd.ownerId,
      );
      notifyListeners();
    }
  } catch (error) {
    print("❌ Failed to update advertisement");
    throw error;
  }
}


  // ✅ Delete advertisement
  Future<void> deleteAdvertisemnt(String id, String token) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB/$id.json?auth=$token');

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw Exception('Failed to delete advertisement');
      }
      _advertisements.removeWhere((ad) => ad.id == id);
      notifyListeners();
    } catch (error) {
      print("❌ Failed to delete advertisement");
      throw error;
    }
  }

  // ✅ Admin - Update status
  Future<void> updateAdvertisementStatus(String id, AdvertisementStatus newStatus, String token) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB/$id.json?auth=$token');

    try {
      await http.patch(url, body: json.encode({
        'status': newStatus.toString().split('.').last,
      }));

      final index = _advertisements.indexWhere((ad) => ad.id == id);
      if (index >= 0) {
        _advertisements[index].status = newStatus;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  // ✅ Admin - Get approved ads
  Future<List<Advertisement>> getApprovedAdvertisements(String token) async {
    return _getAdsByStatus(token, 'approved');
  }

  // ✅ Admin - Get pending ads
  Future<List<Advertisement>> getPendingAdvertisements(String token) async {
    return _getAdsByStatus(token, 'pending');
  }

  // ✅ Admin - Get rejected ads
  Future<List<Advertisement>> getRejectedAdvertisements(String token) async {
    return _getAdsByStatus(token, 'rejected');
  }

  // ✅ Shared method to get ads by status
  Future<List<Advertisement>> _getAdsByStatus(String token, String status) async {
    final url = Uri.parse(
        'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');

    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) return [];

    final List<Advertisement> statusAds = [];
    extractedData.forEach((adId, adData) {
      if (adData['status'] == status) {
        statusAds.add(Advertisement.fromMap(adId, adData));
      }
    });

    return statusAds;
  }
}
