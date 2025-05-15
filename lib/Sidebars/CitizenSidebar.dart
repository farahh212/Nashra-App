import 'package:flutter/material.dart';
import '../screens/emergency_screen.dart';

class CitizenSidebar extends StatelessWidget {
  const CitizenSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFEF5), // Match background color
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add items with spacing between them
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
