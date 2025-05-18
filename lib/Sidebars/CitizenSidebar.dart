import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/emergency_screen.dart';
import '../providers/authProvider.dart' as my_auth; // Import your AuthProvider

class CitizenSidebar extends StatelessWidget {
  const CitizenSidebar({super.key});

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
              title: "Post Advertisement",
              onTap: () {
                Navigator.pushNamed(context, '/advertisement');
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "Contact Government",
              onTap: () {
                // Navigate to Contact Government page
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "Report a Problem",
              onTap: () {
                // Navigate to Report a Problem page
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "Check Emergency numbers",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyNumbersScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
             DrawerItem(
              title: "Check Announcements",
              onTap: () {
                Navigator.pushNamed(context, '/announcements');
                // Navigate to Contact Government page
              },
            ),
            const SizedBox(height: 30),
            DrawerItem(
              title: "Logout",
              onTap: () async {
                await Provider.of<my_auth.AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
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
        Navigator.pop(context); // Close drawer
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
