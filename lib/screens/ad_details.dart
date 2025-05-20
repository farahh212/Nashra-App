import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:nashra_project2/providers/languageProvider.dart';

class AdDetailsPage extends StatefulWidget {
  final String adId;

  const AdDetailsPage({required this.adId, Key? key}) : super(key: key);

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  Advertisement? ad;
  bool _isLoading = true;
  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> translations = {};

  Future<String> _translateText(String text, String targetLang) async {
    if (translations.containsKey('${text}$targetLang')) {
      return translations['${text}$targetLang']!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      translations['${text}$targetLang'] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    Provider.of<AdvertisementProvider>(context, listen: false)
        .getAdvertisementById(widget.adId, token)
        .then((fetchedAd) {
      setState(() {
        ad = fetchedAd;
        _isLoading = false;
      });
    });
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    if (url.startsWith('/data/')) {
      return Image.file(File(url), fit: BoxFit.cover, width: double.infinity);
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      );
    } else if (url.startsWith('data:image/')) {
      return Image.memory(
        base64Decode(url.split(',').last),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<LanguageProvider>(context).currentLanguageCode;

    return Scaffold(
      appBar: AppBar(title: const Text("Advertisement Details")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ad == null
              ? const Center(child: Text("Ad not found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _translateText(ad!.title, currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? ad!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildImage(ad!.imageUrl),
                      const SizedBox(height: 24),
                      FutureBuilder<String>(
                        future: _translateText(ad!.description, currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? ad!.description,
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
