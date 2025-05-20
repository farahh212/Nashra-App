import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../utils/theme.dart';
import '../providers/authProvider.dart' as my_auth;
import '../widgets/bottom_navigation_bar.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Welcome to Nashra',
          style: theme.appBarTheme.titleTextStyle,
        ),
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  isAdmin ? 'Hi, Admin' : 'Hi, User',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin
                      ? 'Welcome to Nashra Government Services'
                      : 'Welcome to Nashra E-Office Services',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feature Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: isAdmin ? _adminFeatures(context) : _citizenFeatures(context),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Highlights
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Highlights',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildHighlights(context, isAdmin),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  List<Widget> _adminFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
        _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
        _buildFeatureTile(context, Icons.campaign, 'Ads', '/gov_advertisement'),
        _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
        _buildFeatureTile(context, Icons.report, 'Reports', '/govreports'),
        _buildFeatureTile(context, Icons.analytics, 'Analytics', '/analytics'),
        _buildFeatureTile(context, Icons.chat, 'Messages', '/gov_chats'),
      ];

  List<Widget> _citizenFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
        _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
        _buildFeatureTile(context, Icons.campaign, 'Ads', '/advertisement'),
        _buildFeatureTile(context, Icons.chat, 'Contact', '/chats'),
        _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
        _buildFeatureTile(context, Icons.report, 'Report', '/reports'),
      ];

  List<Widget> _buildHighlights(BuildContext context, bool isAdmin) => isAdmin
      ? [
          _buildHighlightCard(title: "System Alert", subtitle: "Check latest emergency updates."),
          _buildHighlightCard(title: "New Report Filed", subtitle: "View the latest citizen reports."),
        ]
      : [
          _buildHighlightCard(title: 'New Announcement', subtitle: 'Check out the latest updates from the city council.', onTap: () => Navigator.pushNamed(context, '/announcements')),
          _buildHighlightCard(title: 'Ongoing Poll', subtitle: 'Your feedback matters! Cast your vote now.', onTap: () => Navigator.pushNamed(context, '/polls')),
          _buildHighlightCard(title: 'Featured Ad', subtitle: "Don't miss our latest government announcements.", onTap: () => Navigator.pushNamed(context, '/advertisement')),
          _buildHighlightCard(title: 'Emergency Info', subtitle: 'Access contacts and services for urgent help.', onTap: () => Navigator.pushNamed(context, '/emergency')),
        ];

  Widget _buildFeatureTile(BuildContext context, IconData icon, String label, String route) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(icon, size: 25, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({required String title, required String subtitle, VoidCallback? onTap}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: GestureDetector(
            onTap: onTap,
            child: Card(
              color: theme.cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}