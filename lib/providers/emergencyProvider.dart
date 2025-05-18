import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/emergency_number.dart';

class EmergencyProvider with ChangeNotifier {
  final DatabaseReference _emergencyNumbersRef = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/'
  ).ref().child('emergency_numbers');
  List<EmergencyNumber> _emergencyNumbers = [];
  bool _isLoading = false;
  String? _error;

  List<EmergencyNumber> get emergencyNumbers => _emergencyNumbers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EmergencyProvider() {
    _loadEmergencyNumbers();
  }

  Future<void> _loadEmergencyNumbers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _emergencyNumbersRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _emergencyNumbers = data.entries.map((entry) {
            return EmergencyNumber.fromMap(
              entry.key.toString(),
              Map<String, dynamic>.from(entry.value as Map),
            );
          }).toList();
        } else {
          _emergencyNumbers = [];
        }
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEmergencyNumber(String title, int number, {String titleAr = ''}) async {
    try {
      final newRef = _emergencyNumbersRef.push();
      await newRef.set({
        'title': title,
        'titleAr': titleAr,
        'number': number,
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateEmergencyNumber(String id, String title, int number, {String titleAr = ''}) async {
    try {
      await _emergencyNumbersRef.child(id).update({
        'title': title,
        'titleAr': titleAr,
        'number': number,
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteEmergencyNumber(String id) async {
    try {
      await _emergencyNumbersRef.child(id).remove();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
} 