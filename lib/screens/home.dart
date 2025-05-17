import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../providers/authProvider.dart' as my_auth;
import '../screens/announcementCitizens/announcements.dart';
import '../widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final l10n = AppLocalizations.of(context)!;

    // Redirect non-admin users to announcements page
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Announcements()),
        );
      });
      
      // Return empty container while redirecting
      return Container(color: AppTheme.surfaceColor);
    }

    // Admin UI remains the same
    return Scaffold(
      drawer: const GovSidebar(),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          l10n.governmentDashboard,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeToNashra,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.governmentAdminPortal,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Quick Actions Section
                    Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children: [
                        _buildActionCard(
                          context,
                          l10n.emergencyNumbers,
                          Icons.phone,
                          () => Navigator.pushNamed(context, '/emergency'),
                        ),
                        _buildActionCard(
                          context,
                          l10n.announcements,
                          Icons.announcement,
                          () => Navigator.pushNamed(context, '/announcements'),
                        ),
                        _buildActionCard(
                          context,
                          l10n.advertisements,
                          Icons.campaign,
                          () => Navigator.pushNamed(context, '/advertisement')),
                        _buildActionCard(
                          context,
                          l10n.contactSupport,
                          Icons.contact_support,
                          () {
                            // TODO: Implement contact support functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const CustomBottomNavigationBar(),
        ],
      ),
    );
  }

  // Keep the existing _buildActionCard method
  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}