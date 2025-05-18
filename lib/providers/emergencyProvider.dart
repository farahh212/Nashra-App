import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/emergency_number.dart';

class EmergencyProvider with ChangeNotifier {
  static const _baseUrl = 'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/emergency_numbers';

  List<EmergencyNumber> _emergencyNumbers = [];
  bool _isLoading = false;
  String? _error;

  List<EmergencyNumber> get emergencyNumbers => _emergencyNumbers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ FETCH (GET)
  Future<void> fetchEmergencyNumbers(String token) async {
    final url = Uri.parse('$_baseUrl.json?auth=$token');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      if (extractedData == null) {
        _emergencyNumbers = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<EmergencyNumber> loaded = [];
      extractedData.forEach((id, data) {
        loaded.add(EmergencyNumber.fromMap(id, data));
      });

      _emergencyNumbers = loaded;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ ADD (POST)
  Future<void> addEmergencyNumber(String token, String title, int number, {String titleAr = ''}) async {
    final url = Uri.parse('$_baseUrl.json?auth=$token');

    try {
      final response = await http.post(url, body: json.encode({
        'title': title,
        'titleAr': titleAr,
        'number': number,
      }));

      if (response.statusCode >= 400) throw Exception('Failed to add number');

      await fetchEmergencyNumbers(token);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // ✅ UPDATE (PATCH)
  Future<void> updateEmergencyNumber(String token, String id, String title, int number, {String titleAr = ''}) async {
    final url = Uri.parse('$_baseUrl/$id.json?auth=$token');

    try {
      final response = await http.patch(url, body: json.encode({
        'title': title,
        'titleAr': titleAr,
        'number': number,
      }));

      if (response.statusCode >= 400) throw Exception('Failed to update number');

      await fetchEmergencyNumbers(token);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // ✅ DELETE
  Future<void> deleteEmergencyNumber(String token, String id) async {
    final url = Uri.parse('$_baseUrl/$id.json?auth=$token');

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) throw Exception('Failed to delete number');

      await fetchEmergencyNumbers(token);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}
