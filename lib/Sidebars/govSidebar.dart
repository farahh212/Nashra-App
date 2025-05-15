import 'package:flutter/material.dart';
import '../screens/emergency_screen.dart';
import '../screens/announcements.dart';
import '../screens/advertisement_screen.dart';

class GovSidebar extends StatelessWidget {
  const GovSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFEF5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerItem(
              title: "Manage Emergency Numbers",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyNumbersScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "Manage Announcements",
              onTap: () {
                Navigator.pushNamed(context, '/announcements');
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "Manage Advertisements",
              onTap: () {
                Navigator.pushNamed(context, '/gov_advertisement');
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "View Reports",
              onTap: () {
                // Navigate to Reports page
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const DrawerItem({
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[900],
        ),
      ),
    );
  }
}
