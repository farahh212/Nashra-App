import 'package:flutter/material.dart';
import 'package:nashra_project2/screens/poll_results_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/announcementCitizens/announcements.dart';
import '../screens/advertisement_screen.dart';
import '../screens/analytics_screen.dart';

class GovSidebar extends StatelessWidget {
  const GovSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: ListView(
            children: [
              const _GovProfileCard(),
              const SizedBox(height: 20),
              _DrawerSection(
                title: "Control Panel",
                items: [
                  _DrawerItem(
                    icon: Icons.phone,
                    title: "Manage Emergency Numbers",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmergencyNumbersScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.announcement,
                    title: "Manage Announcements",
                    onTap: () {
                      Navigator.pushNamed(context, '/announcements');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.campaign,
                    title: "Manage Advertisements",
                    onTap: () {
                      Navigator.pushNamed(context, '/gov_advertisement');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.analytics,
                    title: "Analytics Dashboard",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.report,
                    title: "View Reports",
                    onTap: () {
                      // Add your navigation logic
                    },
                  ),
                     _DrawerItem(
                    icon: Icons.report,
                    title: "Poll results",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
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

class _GovProfileCard extends StatelessWidget {
  const _GovProfileCard();

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
              backgroundImage: AssetImage('assets/images/admin_avatar.png'), // replace with your admin image
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Government Portal", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.settings)
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      leading: Icon(icon, size: 28, color: Colors.green[900]), // 👈 Larger icon size
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.green[900]),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
