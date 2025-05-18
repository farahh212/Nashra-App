// Emergency Service
// This file will contain emergency-related services and functionality 

import 'package:firebase_database/firebase_database.dart';
import '../models/emergency_number.dart';
import '../utils/constants.dart';

class EmergencyService {
  final DatabaseReference _emergencyNumbersRef =
      FirebaseDatabase.instance.ref().child('emergency_numbers');

  // Get all emergency numbers
  Stream<List<EmergencyNumber>> getEmergencyNumbers() {
    return _emergencyNumbersRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        return EmergencyNumber.fromMap(
          entry.key.toString(),
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  // Add a new emergency number
  Future<void> addEmergencyNumber(String title, int number) async {
    final newRef = _emergencyNumbersRef.push();
    await newRef.set({
      'title': title,
      'number': number,
    });
  }

  // Update an existing emergency number
  Future<void> updateEmergencyNumber(String id, String title, int number) async {
    await _emergencyNumbersRef.child(id).update({
      'title': title,
      'number': number,
    });
  }

  // Delete an emergency number
  Future<void> deleteEmergencyNumber(String id) async {
    await _emergencyNumbersRef.child(id).remove();
  }
} 