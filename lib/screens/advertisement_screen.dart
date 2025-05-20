import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:nashra_project2/models/index.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/languageProvider.dart';
import 'package:nashra_project2/screens/ad_card.dart';
import 'package:nashra_project2/screens/create_ad_screen.dart';
import 'package:nashra_project2/screens/myAdvertisementScreen.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';

class AdvertisementScreen extends StatefulWidget {
  @override
  _AdvertisementScreenState createState() => _AdvertisementScreenState();
}

class _AdvertisementScreenState extends State<AdvertisementScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      await Provider.of<AdvertisementProvider>(context, listen: false)
          .fetchAdvertisements(token);
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<String> _translateText(String text, String targetLang) async {
    if (_translations.containsKey('${text}_$targetLang')) {
      return _translations['${text}_$targetLang']!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations['${text}_$targetLang'] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, String currentLanguage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.announcement,
            size: 48,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: _translateText('No ads available', currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'No ads available',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _translateText('Be the first to create one!', currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Be the first to create one!',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAdScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            child: FutureBuilder<String>(
              future: _translateText('Create Ad', currentLanguage),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? 'Create Ad');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String currentLanguage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: _translateText('Failed to load ads', currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Failed to load ads',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAdvertisements,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            child: FutureBuilder<String>(
              future: _translateText('Retry', currentLanguage),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? 'Retry');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ads = Provider.of<AdvertisementProvider>(context)
        .advertisements
        .where((ad) => ad.status == AdvertisementStatus.approved)
        .toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: (isDark ? Colors.black : Colors.white),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Color(0xFF1976D2),
        ),
        title: Text(
          "Advertisement",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Color(0xFF1976D2),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: isDark ? Colors.white : Color(0xFF1976D2)),
            tooltip: 'Create Ad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAdScreen()),
              );
            },
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAdvertisementsScreen()),
              );
            },
            label: FutureBuilder<String>(
              future: _translateText('My Ads', currentLanguage),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'My Ads',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF1976D2),
                  ),
                );
              }
            ),
            icon: Icon(Icons.person,
                color: isDark ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF1976D2)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            )
          : _hasError
              ? _buildErrorState(context, isDark, currentLanguage)
              : ads.isEmpty
                  ? _buildEmptyState(context, isDark, currentLanguage)
                  : RefreshIndicator(
                      onRefresh: _loadAdvertisements,
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: ads.length,
                        itemBuilder: (context, index) => AdCard(ad: ads[index]),
                      ),
                    ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}