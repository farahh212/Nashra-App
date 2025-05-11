import 'package:flutter/material.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdvertisementProvider with ChangeNotifier{
  List<Advertisement> _advertisements = [];
  List<Advertisement> get advertisements {
    return [..._advertisements];
  }
  //create a new advertisement
  Future<void>addAdvertisement(Advertisement advertisement, String token) {
    var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
    
    return http.post(advertisementURL,
    body: json.encode({
      'title': advertisement.title,
      'description': advertisement.description,
      'imageUrl': advertisement.imageUrl,
      'status': advertisement.status.toString().split('.').last,
    })).then((response) {
      final newAd = Advertisement(
        id: json.decode(response.body)['name'],
        title: advertisement.title,
        description: advertisement.description,
        imageUrl: advertisement.imageUrl,
        status: advertisement.status,
      );
      _advertisements.add(newAd);
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
    
  }
//get all advertisements
  Future<void> fetchAdvertisements(String token) {
    var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
    
    return http.get(advertisementURL).then((response) {
      final List<Advertisement> loadedAds = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((adId, adData) {
        loadedAds.add(Advertisement(
          id: adId,
          title: adData['title'],
          description: adData['description'],
          imageUrl: adData['imageUrl'],
          status: AdvertisementStatus.values.firstWhere(
            (e) => e.toString().split('.').last == adData['status'],
            orElse: () => AdvertisementStatus.pending,
          ),
        ));
      });
      _advertisements = loadedAds;
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }
//get advertisement by id(show the user his ads)
Future<Advertisement?> getAdvertisementById(String id, String token) {
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
  return http.get(advertisementURL).then((response) {
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null || !extractedData.containsKey(id)) {
      return null;
    }
    final adData = extractedData[id];
    final advertisement = Advertisement(
      id: id,
      title: adData['title'],
      description: adData['description'],
      imageUrl: adData['imageUrl'],
      status: AdvertisementStatus.values.firstWhere(
        (e) => e.toString().split('.').last == adData['status'],
        orElse: () => AdvertisementStatus.pending,
      ),
    );
    notifyListeners();
    return advertisement;
  }).catchError((error) {
    throw error;
  });
}
//update advertisement (user can update his ad)
Future<void>updateAdvertisement(String id, Advertisement updateAd, String token)async{
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
    try{
      await http.patch(advertisementURL, body: json.encode({
        'title':updateAd.title,
        'description': updateAd.description,
        'imageUrl':advertisementURL,
        'status':updateAd.status.toString().split('.').last,
      }));
      final adIndex = _advertisements.indexWhere((ad) => ad.id == id);
      if(adIndex >= 0){
        _advertisements[adIndex] = updateAd;
        notifyListeners();
      }
    }catch(error){
      print("faild to update advertisement");
      throw error;
    }
  }

//delete advertisement(user can delete his ad)
Future<void>deleteAdvertisemnt(String id, String token)async{
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
    try{
      final response  = await http.delete(advertisementURL);
      if(response.statusCode >= 400){
        throw Exception('Failed to delete advertisement');
      }
      _advertisements.removeWhere((ad) => ad.id == id);
      notifyListeners();
    }catch(error){
      print("failed to delete advertisement");
      throw error;
    }
  }
  /////ADMIN PART (GOV)/////////
//update  advertisement status (admin can update the ad status) 
Future<void>updateAdvertisementStatus(String id, AdvertisementStatus newStatus, String token)async{
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
    try{
      await http.patch(advertisementURL, body: json.encode({
        'status':newStatus.toString().split('.').last,
      }));
      final adIndex = _advertisements.indexWhere((ad) => ad.id == id);
      if(adIndex >= 0){
        _advertisements[adIndex].status = newStatus;
        notifyListeners();
      }
    }catch(error){
      print("failed to update advertisement status");
      throw error;
    }
  }
//get all approved advertisements (admin can get all approved ads)
Future<List<Advertisement>> getApprovedAdvertisements(String token) async {
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
  final response = await http.get(advertisementURL);
  final extractedData = json.decode(response.body) as Map<String, dynamic>;
  if (extractedData == null) {
    return [];
  }
  final List<Advertisement> approvedAds = [];
  extractedData.forEach((adId, adData) {
    if (adData['status'] == 'approved') {
      approvedAds.add(Advertisement(
        id: adId,
        title: adData['title'],
        description: adData['description'],
        imageUrl: adData['imageUrl'],
        status: AdvertisementStatus.approved,
      ));
    }
  });
  return approvedAds;
}
//get all pending advertisements (admin can get all pending ads)
Future<List<Advertisement>> getPendingAdvertisements(String token) async {
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
  final response = await http.get(advertisementURL);
  final extractedData = json.decode(response.body) as Map<String, dynamic>;
  if (extractedData == null) {
    return [];
  }
  final List<Advertisement> pendingAds = [];
  extractedData.forEach((adId, adData) {
    if (adData['status'] == 'pending') {
      pendingAds.add(Advertisement(
        id: adId,
        title: adData['title'],
        description: adData['description'],
        imageUrl: adData['imageUrl'],
        status: AdvertisementStatus.approved,
      ));
    }
  });
  return pendingAds;
}
//get all rejected advertisements (admin can get all rejected ads)
Future<List<Advertisement>> getRejectedAdvertisements(String token) async {
  var advertisementURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AdvertisementDB.json?auth=$token');
  final response = await http.get(advertisementURL);
  final extractedData = json.decode(response.body) as Map<String, dynamic>;
  if (extractedData == null) {
    return [];
  }
  final List<Advertisement> rejectedAds = [];
  extractedData.forEach((adId, adData) {
    if (adData['status'] == 'rejected') {
      rejectedAds.add(Advertisement(
        id: adId,
        title: adData['title'],
        description: adData['description'],
        imageUrl: adData['imageUrl'],
        status: AdvertisementStatus.approved,
      ));
    }
  });
  return rejectedAds;
}
}