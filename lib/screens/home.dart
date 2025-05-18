import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../utils/theme.dart';
import '../providers/authProvider.dart' as my_auth;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    final green = const Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 254, 254),
      drawer: isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        title: const Text(
          'Welcome to Nashra',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: green,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(height: 16),
                Text(
                  isAdmin ? 'Hi, Admin' : 'Hi, User',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin
                      ? 'Welcome to Nashra Government Services'
                      : 'Welcome to Nashra E-Office Services',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feature Cards (Wrap version to prevent overflow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: green),
            ),
          ),
          const SizedBox(height: 12),
          ..._buildHighlights(context, isAdmin),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Language'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  List<Widget> _adminFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
        _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
        _buildFeatureTile(context, Icons.campaign, 'Ads', '/gov_advertisement'),
        _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
        _buildFeatureTile(context, Icons.report, 'Reports', '/reports'),
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
          _buildHighlightCard(title: 'Featured Ad', subtitle: 'Don’t miss our latest government announcements.', onTap: () => Navigator.pushNamed(context, '/advertisement')),
          _buildHighlightCard(title: 'Emergency Info', subtitle: 'Access contacts and services for urgent help.', onTap: () => Navigator.pushNamed(context, '/emergency')),
        ];

  Widget _buildFeatureTile(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Icon(icon, size: 25, color: const Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({required String title, required String subtitle, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}