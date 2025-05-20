import 'package:flutter/material.dart';
import 'package:nashra_project2/models/index.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/screens/ad_card.dart';
import 'package:nashra_project2/screens/create_ad_screen.dart';
import 'package:nashra_project2/screens/myAdvertisementScreen.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class AdvertisementScreen extends StatefulWidget {
  @override
  _AdvertisementScreenState createState() => _AdvertisementScreenState();
}

class _AdvertisementScreenState extends State<AdvertisementScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;

      Provider.of<AdvertisementProvider>(context, listen: false)
          .fetchAdvertisements(token)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ads = Provider.of<AdvertisementProvider>(context)
        .advertisements
        .where((ad) => ad.status == AdvertisementStatus.approved)
        .toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? Colors.black : Colors.white),
        title: Text(
          "Advertisement",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2)),
            tooltip: 'Create Ad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAdScreen()),
              );
            },
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAdvertisementsScreen()),
              );
            },
            label: Text(
              "My Ads",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
           
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            )
          : ads.isEmpty
              ? Center(
                  child: Text(
                    "No ads available.",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: ads.length,
                  itemBuilder: (context, index) => AdCard(ad: ads[index]),
                ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
