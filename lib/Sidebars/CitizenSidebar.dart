import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/emergency_screen.dart';
import '../providers/authProvider.dart' as my_auth;
import '../chat/messagePage_citiz.dart';
import '../screens/reports/reports_screen.dart';
import '../utils/theme.dart';
import '../../providers/languageProvider.dart';
import 'package:translator/translator.dart';
import '../providers/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitizenSidebar extends StatefulWidget {
  const CitizenSidebar({super.key});

  @override
  State<CitizenSidebar> createState() => _CitizenSidebarState();
}

class _CitizenSidebarState extends State<CitizenSidebar> {
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  String _navigationText = 'Navigation';
  String _createAdvertisementText = 'Create Advertisement';
  String _contactGovernmentText = 'Contact Government';
  String _reportProblemText = 'Report a Problem';
  String _emergencyNumbersText = 'Emergency Numbers';
  String _checkAnnouncementsText = 'Check Announcements';
  String _pollsText = 'Polls';
  String _settingsText = 'Settings';
  String _logoutText = 'Logout';
  String _citizenPortalText = 'Citizen Portal';

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
    
    _navigationText = await _translateText('Navigation', currentLang);
    _createAdvertisementText = await _translateText('Create Advertisement', currentLang);
    _contactGovernmentText = await _translateText('Contact Government', currentLang);
    _reportProblemText = await _translateText('Report a Problem', currentLang);
    _emergencyNumbersText = await _translateText('Emergency Numbers', currentLang);
    _checkAnnouncementsText = await _translateText('Check Announcements', currentLang);
    _pollsText = await _translateText('Polls', currentLang);
    _settingsText = await _translateText('Settings', currentLang);
    _logoutText = await _translateText('Logout', currentLang);
    _citizenPortalText = await _translateText('Citizen Portal', currentLang);
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: ListView(
            children: [
              _UserProfileCard(citizenPortalText: _citizenPortalText),
              const SizedBox(height: 20),
              _DrawerSection(
                title: _navigationText,
                items: [
                  _DrawerItem(
                    icon: Icons.post_add,
                    title: _createAdvertisementText,
                    onTap: () {
                      Navigator.pushNamed(context, '/advertisement');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.chat,
                    title: _contactGovernmentText,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CitizenMessageWrapper()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.report_problem,
                    title: _reportProblemText,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AllReports()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.local_phone,
                    title: _emergencyNumbersText,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EmergencyNumbersScreen()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.announcement,
                    title: _checkAnnouncementsText,
                    onTap: () {
                      Navigator.pushNamed(context, '/announcements');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.poll,
                    title: _pollsText,
                    onTap: () {
                      Navigator.pushNamed(context, '/polls');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DrawerSection(
                title: _settingsText,
                items: [
                  _DrawerItem(
                    icon: Icons.logout,
                    title: _logoutText,
                    onTap: () async {
                      await Provider.of<my_auth.AuthProvider>(context, listen: false).logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
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

class _UserProfileCard extends StatefulWidget {
  final String citizenPortalText;

  const _UserProfileCard({required this.citizenPortalText});

  @override
  _UserProfileCardState createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<_UserProfileCard> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  void _loadEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = await getNameByUid(authProvider.userId);
    setState(() {
      userEmail = email;
    });
    print('User email: $userEmail');
  }

  Future<String> getNameByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['name'] != null) {
      return doc.data()?['name'];
    }
    return 'government'; // default fallback
  }

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
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userEmail ?? "User",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                  ),
                  Text(
                    widget.citizenPortalText,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
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
