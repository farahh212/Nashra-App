import 'package:flutter/material.dart';
import 'package:nashra_project2/screens/poll_results_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/announcementCitizens/announcements.dart';
import '../screens/advertisement_screen.dart';
import '../screens/analytics_screen.dart';
import '../chat/ChatsPage.dart';
import '../screens/reports/gov_reports_screen.dart';
import '../utils/theme.dart';

class GovSidebar extends StatelessWidget {
  const GovSidebar({super.key});

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ViewReportsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.message,
                    title: "View Messages",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.poll,
                    title: "Poll Results",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                      );
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
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  Text(
                    "Government Portal",
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.settings,
              color: theme.colorScheme.primary,
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
    return Card(
      elevation: 1.5,
      color: theme.cardTheme.color,
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
                color: theme.textTheme.titleLarge?.color,
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        size: 28,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
