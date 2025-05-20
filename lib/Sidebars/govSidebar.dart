import 'package:flutter/material.dart';
import '../screens/poll_results_screen.dart';
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

class GovSidebar extends StatefulWidget {
  const GovSidebar({super.key});

  @override
  State<GovSidebar> createState() => _GovSidebarState();
}

class _GovSidebarState extends State<GovSidebar> {
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  String _controlPanelText = 'Control Panel';
  String _manageEmergencyText = 'Manage Emergency Numbers';
  String _manageAnnouncementsText = 'Manage Announcements';
  String _manageAdvertisementsText = 'Manage Advertisements';
  String _analyticsDashboardText = 'Analytics Dashboard';
  String _viewReportsText = 'View Reports';
  String _viewMessagesText = 'View Messages';
  String _pollResultsText = 'Poll Results';
  String _adminText = 'Admin';
  String _govPortalText = 'Government Portal';

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

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;
    
    _controlPanelText = await _translateText('Control Panel', currentLang);
    _manageEmergencyText = await _translateText('Manage Emergency Numbers', currentLang);
    _manageAnnouncementsText = await _translateText('Manage Announcements', currentLang);
    _manageAdvertisementsText = await _translateText('Manage Advertisements', currentLang);
    _analyticsDashboardText = await _translateText('Analytics Dashboard', currentLang);
    _viewReportsText = await _translateText('View Reports', currentLang);
    _viewMessagesText = await _translateText('View Messages', currentLang);
    _pollResultsText = await _translateText('Poll Results', currentLang);
    _adminText = await _translateText('Admin', currentLang);
    _govPortalText = await _translateText('Government Portal', currentLang);
    
    if (mounted) {
      setState(() {});
    }
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
              _GovProfileCard(
                adminText: _adminText,
                govPortalText: _govPortalText,
              ),
              const SizedBox(height: 20),
              _DrawerSection(
                title: _controlPanelText,
                items: [
                  _DrawerItem(
                    icon: Icons.phone,
                    title: _manageEmergencyText,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyNumbersScreen()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.announcement,
                    title: _manageAnnouncementsText,
                    onTap: () => Navigator.pushNamed(context, '/announcements'),
                  ),
                  _DrawerItem(
                    icon: Icons.campaign,
                    title: _manageAdvertisementsText,
                    onTap: () => Navigator.pushNamed(context, '/gov_advertisement'),
                  ),
                  _DrawerItem(
                    icon: Icons.analytics,
                    title: _analyticsDashboardText,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.report,
                    title: _viewReportsText,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewReportsPage()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.message,
                    title: _viewMessagesText,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatsPage()),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.poll,
                    title: _pollResultsText,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PollResultsScreen()),
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
  final String adminText;
  final String govPortalText;

  const _GovProfileCard({
    required this.adminText,
    required this.govPortalText,
  });

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
                    adminText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                  ),
                  Text(
                    govPortalText,
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
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
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
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

