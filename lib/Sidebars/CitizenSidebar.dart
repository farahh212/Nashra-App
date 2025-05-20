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

class CitizenSidebar extends StatelessWidget {
  const CitizenSidebar({super.key});

  Future<String> _translateText(String text, String targetLang) async {
    final translator = GoogleTranslator();
    final translations = <String, String>{};
    final key = '${text}_$targetLang';
    if (translations.containsKey(key)) {
      return translations[key]!;
    }
    try {
      final translation = await translator.translate(text, to: targetLang);
      translations[key] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  // Helper widget to build a translated drawer item title
  Widget _translatedDrawerItemTitle(BuildContext context, String text) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;

    return FutureBuilder<String>(
      future: _translateText(text, currentLang),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Text(snapshot.data!);
        } else {
          return Text(text);
        }
      },
    );
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
              _UserProfileCard(),
              const SizedBox(height: 20),
              _DrawerSection(
                title: "Navigation",
                items: [
                  _DrawerItem(
                    icon: Icons.post_add,
                    titleWidget: _translatedDrawerItemTitle(context, "Create Advertisement"),
                    onTap: () {
                      Navigator.pushNamed(context, '/advertisement');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.chat,
                    titleWidget: _translatedDrawerItemTitle(context, "Contact Government"),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CitizenMessageWrapper()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.report_problem,
                    titleWidget: _translatedDrawerItemTitle(context, "Report a Problem"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AllReports()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.local_phone,
                    titleWidget: _translatedDrawerItemTitle(context, "Emergency Numbers"),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EmergencyNumbersScreen()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.announcement,
                    titleWidget: _translatedDrawerItemTitle(context, "Check Announcements"),
                    onTap: () {
                      Navigator.pushNamed(context, '/announcements');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.poll,
                    titleWidget: _translatedDrawerItemTitle(context, "Polls"),
                    onTap: () {
                      Navigator.pushNamed(context, '/polls');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DrawerSection(
                title: "Settings",
                items: [
                  _DrawerItem(
                    icon: Icons.logout,
                    titleWidget: _translatedDrawerItemTitle(context, "Logout"),
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
                    "Citizen Portal",
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
  final Widget titleWidget; // Changed from String title to Widget for flexibility
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
        color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
      ),
      title: DefaultTextStyle(
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
        child: titleWidget,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
