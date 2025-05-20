import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_number.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../providers/emergencyProvider.dart';
import '../providers/authProvider.dart' as my_auth;
import '../providers/languageProvider.dart';
import '../widgets/bottom_navigation_bar.dart';

class EmergencyNumbersScreen extends StatefulWidget {
  const EmergencyNumbersScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyNumbersScreen> createState() => _EmergencyNumbersScreenState();
}

class _EmergencyNumbersScreenState extends State<EmergencyNumbersScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  bool _isAdmin = false;
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      final token = authProvider.token;
      Provider.of<EmergencyProvider>(context, listen: false).fetchEmergencyNumbers(token);
    });
  }

  Future<void> _launchDialer(int number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number.toString());
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer')),
      );
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
      return text;
    }
  }

  Future<void> _checkAdminStatus() async {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    setState(() {
      _isAdmin = authProvider.isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _isAdmin ? GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: FutureBuilder<String>(
          future: _translateText(
            _isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers',
            currentLanguage,
          ),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? (_isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers'),
              style: TextStyle(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            );
          },
        ),
        iconTheme: IconThemeData(
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = provider.emergencyNumbers;
          if (items.isEmpty) {
            return Center(child: Text('No emergency numbers found'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final contact = items[i];
                return InkWell(
                  onTap: () => _launchDialer(contact.number),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone, color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String>(
                                future: _translateText(contact.title, currentLanguage),
                                builder: (context, snapshot) => Text(
                                  snapshot.data ?? contact.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                contact.number.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    super.dispose();
  }
}