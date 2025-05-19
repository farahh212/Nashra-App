import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/emergency_screen.dart';
import '../providers/authProvider.dart' as my_auth;
import '../chat/messagePage_citiz.dart';
import '../providers/authProvider.dart' as my_auth; // Import your AuthProvider
import '../screens/reports/reports_screen.dart';

class CitizenSidebar extends StatelessWidget {
  const CitizenSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: ListView(
            children: [
              const _UserProfileCard(),
              const SizedBox(height: 20),
              _DrawerSection(
                title: "Navigation",
                items: [
                  _DrawerItem(icon: Icons.post_add, title: "Post Advertisement", onTap: () {
                    Navigator.pushNamed(context, '/advertisement');
                  }),
                  _DrawerItem(icon: Icons.chat, title: "Contact Government", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CitizenMessageWrapper()));
                  }),
                  _DrawerItem(icon: Icons.report_problem, title: "Report a Problem", onTap: () {
                    // Your logic
                  }),
                  _DrawerItem(icon: Icons.local_phone, title: "Emergency Numbers", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyNumbersScreen()));
                  }),
                  _DrawerItem(icon: Icons.announcement, title: "Check Announcements", onTap: () {
                    Navigator.pushNamed(context, '/announcements');
                  }),
                   _DrawerItem(icon: Icons.poll, title: "Polls", onTap: () {
                    Navigator.pushNamed(context, '/polls');
                  }),
                ],
              ),
              const SizedBox(height: 20),
              _DrawerSection(
                title: "Settings",
                items: [
                  _DrawerItem(icon: Icons.logout, title: "Logout", onTap: () async {
                    await Provider.of<my_auth.AuthProvider>(context, listen: false).logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                  Text("Citizen Portal", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.more_vert, color: Color(0xFF2196F3))
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
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2196F3))),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Color(0xFF2196F3)),
      title: Text(title, style: TextStyle(fontSize: 16, color: Color(0xFF2196F3))),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
