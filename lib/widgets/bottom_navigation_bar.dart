import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/languageProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/authProvider.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  String? userEmail;

    @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  void _loadEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = await getEmailByUid(authProvider.userId);
    setState(() {
      userEmail = email;
    });
  }
  Future<String> getEmailByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['email'] != null) {
      return doc.data()?['email'];
    }
    return 'government@nashra.com'; // default fallback
  }

  Future<int> getUnreadNotificationCount() async {
  if (userEmail == null) return 0;

  final snapshot = await FirebaseFirestore.instance
      .collection('notifications')
      .where('userEmail', isEqualTo: userEmail)
      .where('isRead', isEqualTo: false)
      .get();

  return snapshot.docs.length;
}
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: primaryColor, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.notifications_outlined, color: primaryColor, size: 28),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/notifications');
          //   },
          // ),
          userEmail == null
    ? IconButton(
        icon: const Icon(Icons.notifications_outlined, size: 28),
        color: primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/notifications');
        },
      )
    : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userEmail', isEqualTo: userEmail)
            .where('isRead', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data?.docs.length ?? 0;

          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                color: primaryColor,
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),

          PopupMenuButton<String>(
            icon: Icon(Icons.language, color: primaryColor, size: 28),
            onSelected: (String langCode) {
              languageProvider.setLocale(langCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed to ${LanguageProvider.supportedLanguages[langCode]}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            itemBuilder: (BuildContext context) {
              return languageProvider.availableLanguages.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      if (entry.key == languageProvider.currentLanguageCode)
                        Icon(Icons.check, color: primaryColor, size: 20),
                      SizedBox(width: entry.key == languageProvider.currentLanguageCode ? 8 : 28),
                      Text(entry.value),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: primaryColor, size: 28),
            onPressed: () {
              // Add profile navigation here
            },
          ),
        ],
      ),
    );
  }
} 