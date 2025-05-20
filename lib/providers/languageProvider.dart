import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  // Map of supported languages with their display names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'hi': 'हिंदी',
    'ur': 'اردو',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'tr': 'Türkçe',
    'ms': 'Bahasa Melayu',
    'id': 'Bahasa Indonesia'
  };

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  String get currentLanguageName => supportedLanguages[currentLanguageCode] ?? 'English';

  void setLocale(String languageCode) {
    if (_currentLocale.languageCode != languageCode && supportedLanguages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  // Get list of available languages
  List<MapEntry<String, String>> get availableLanguages => supportedLanguages.entries.toList();
} 