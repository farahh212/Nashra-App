import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/languageProvider.dart';

class EmergencyNumber {
  final String id;
  final String title;
  final String titleAr;
  final int number;

  EmergencyNumber({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.number,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'titleAr': titleAr,
      'number': number,
    };
  }

  factory EmergencyNumber.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyNumber(
      id: id,
      title: map['title'] ?? '',
      titleAr: map['titleAr'] ?? '',
      number: map['number'] ?? 0,
    );
  }

  String getTranslatedTitle(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return languageProvider.currentLocale.languageCode == 'ar' ? titleAr : title;
  }
} 