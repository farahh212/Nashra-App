import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

import '../models/advertisement.dart';
import '../providers/languageProvider.dart';
import '../screens/ad_details.dart';

class AdCard extends StatelessWidget {
  final Advertisement ad;
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _translations = {};

  AdCard({required this.ad});

  Future<String> _translateText(String text, String targetLang) async {
    final key = '${text}_$targetLang';
    if (_translations.containsKey(key)) return _translations[key]!;

    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations[key] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLanguage = Provider.of<LanguageProvider>(context).currentLanguageCode;

    Widget imageWidget;
    final url = ad.imageUrl;

    if (url != null && url.startsWith('/data/')) {
      imageWidget = Image.file(
        File(url),
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      );
    } else if (url != null && url.startsWith('http')) {
      imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          width: double.infinity,
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Icon(Icons.broken_image, size: 40, color: isDark ? Colors.grey[400] : Colors.grey),
        ),
      );
    } else if (url != null && url.startsWith('data:image/')) {
      imageWidget = Image.memory(
        base64Decode(url.split(',').last),
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      );
    } else {
      imageWidget = Container(
        height: 200,
        width: double.infinity,
        color: isDark ? Colors.grey[800] : Colors.grey.shade200,
        child: Icon(Icons.image_not_supported, size: 40, color: isDark ? Colors.grey[400] : Colors.grey),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageWidget,
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: _translateText(ad.title, currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? ad.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          FutureBuilder<String>(
            future: _translateText(ad.description, currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? ad.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdDetailsPage(adId: ad.id)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: FutureBuilder<String>(
                future: _translateText("Check Ad", currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Check Ad",
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
