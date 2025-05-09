
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nashra_project2/models/advertisement.dart';

class AdvertisementServices{
  final CollectionReference _advertisementCollection = FirebaseFirestore.instance.collection('advertisement');

  Future<List<Advertisement>> getApprovedAdvertisements() async{
    final snapshot  = await _advertisementCollection.where('status', isEqualTo: 'approved').get();
    return snapshot.docs.map((doc)=> Advertisement.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }
  Future<void> addAdvertisement(Advertisement advertisement) async{
    await _advertisementCollection.add(advertisement.toMap());
  }
  Future<void> updateAdvertisementStatus(String id, AdvertisementStatus newStatus) async{
    await _advertisementCollection.doc(id).update({'status': newStatus.toString().split('.').last});
  }
}