import 'package:flutter/material.dart';
import 'package:nashra_project2/screens/poll_results_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/announcementCitizens/announcements.dart';
import '../screens/advertisement_screen.dart';
import '../screens/analytics_screen.dart';
import '../chat/ChatsPage.dart';
import '../screens/reports/gov_reports_screen.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../../providers/languageProvider.dart';
import 'package:translator/translator.dart';
import '../providers/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GovSidebar extends StatelessWidget {
  GovSidebar({super.key});

  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> _translations = {};

  Future<String> _translateText(String text, String targetLang) async {
    final key = '${text}_$targetLang';
    if (_translations.containsKey(key)) {
      return _translations[key]!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations[key] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  Widget _translatedDrawerItemTitle(BuildContext context, String text) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;

    return FutureBuilder<String>(
      future: _translateText(text, currentLang),
      builder: (context, snapshot) {
        return Text(
          snapshot.hasData ? snapshot.data! : text,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF64B5F6)
                : Color(0xFF1976D2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: ListView(
            children: [
              _GovProfileCard(),
              const SizedBox(height: 20),
              _DrawerSection(
                title: "Control Panel",
                items: [
                  _DrawerItem(
                    icon: Icons.phone,
                    titleWidget: _translatedDrawerItemTitle(context, "Manage Emergency Numbers"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyNumbersScreen()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.announcement,
                    titleWidget: _translatedDrawerItemTitle(context, "Manage Announcements"),
                    onTap: () => Navigator.pushNamed(context, '/announcements'),
                  ),
                  _DrawerItem(
                    icon: Icons.campaign,
                    titleWidget: _translatedDrawerItemTitle(context, "Manage Advertisements"),
                    onTap: () => Navigator.pushNamed(context, '/gov_advertisement'),
                  ),
                  _DrawerItem(
                    icon: Icons.analytics,
                    titleWidget: _translatedDrawerItemTitle(context, "Analytics Dashboard"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.report,
                    titleWidget: _translatedDrawerItemTitle(context, "View Reports"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewReportsPage()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.message,
                    titleWidget: _translatedDrawerItemTitle(context, "View Messages"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatsPage()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.poll,
                    titleWidget: _translatedDrawerItemTitle(context, "Poll Results"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _GovProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? theme.cardTheme.color : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? Color(0xFF1976D2) : Color(0xFF2196F3),
              child: Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                  ),
                  Text(
                    "Government Portal",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.settings,
              color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _DrawerSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1.5,
      color: isDark ? theme.cardTheme.color : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Widget titleWidget; // Changed from String title
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.titleWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        size: 28,
        color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
      ),
      title: titleWidget,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

