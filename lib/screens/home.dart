import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../providers/authProvider.dart' as my_auth;
import '../screens/announcementCitizens/announcements.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      drawer: isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Welcome to Nashra',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hi, User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Welcome to Nashra E-Office Services',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
                    _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
                    _buildFeatureTile(context, Icons.campaign, 'Ads', '/advertisement'),
                    _buildFeatureTile(context, Icons.report_problem, 'Report Issue', '/report'),
                    _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
                    _buildFeatureTile(context, Icons.phone, 'Contact government', '/message'),
                    // _buildFeatureTile(context, Icons.phone_in_talk, 'Hotline', '/emergency'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Highlights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightCard(
                    context,
                    title: 'New Announcement',
                    subtitle: 'Check out the latest updates from the city council.',
                    onTap: () => Navigator.pushNamed(context, '/announcements'),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightCard(
                    context,
                    title: 'Ongoing Poll',
                    subtitle: 'Your feedback matters! Cast your vote now.',
                    onTap: () => Navigator.pushNamed(context, '/polls'),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightCard(
                    context,
                    title: 'Featured Ad',
                    subtitle: 'Don’t miss our latest government announcements.',
                    onTap: () => Navigator.pushNamed(context, '/advertisement'),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightCard(
                    context,
                    title: 'Emergency Info',
                    subtitle: 'Access contacts and services for urgent help.',
                    onTap: () => Navigator.pushNamed(context, '/emergency'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'language'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'notofications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(BuildContext context, {required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}