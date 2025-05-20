


// text_moderation.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TextModeration {
  static const String _apiKey = '5185bab0-b26e-4266-8004-f496b0a0a6e2';
  static const String _apiUrl = 'https://api.deepai.org/api/text-moderation';

  // Local profanity filter as fallback
  static final List<String> _bannedWords = [
    'stupid', 'idiot', 'dumb', 'hate', 'retard', 
    'moron', 'fool', 'worthless'
  ];

  static Future<bool> isContentSafe(String text) async {
    // First check local banned words
    if (_containsBannedWords(text)) {
      return false;
    }

    // Then check with DeepAI API
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'api-key': _apiKey},
        body: {'text': text},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['output'] != 'unsafe';
      }
      return true; // Fail-safe if API fails
    } catch (e) {
      print('Moderation API error: $e');
      return true; // Allow if API fails
    }
  }

  static bool _containsBannedWords(String text) {
    final lowerText = text.toLowerCase();
    return _bannedWords.any((word) => lowerText.contains(word));
  }
}