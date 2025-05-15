import 'package:flutter/material.dart';
import 'package:nashra_project2/models/index.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/screens/ad_card.dart';
import 'package:nashra_project2/screens/create_ad_screen.dart';
import 'package:nashra_project2/screens/myAdvertisementScreen.dart';

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

  return Scaffold(
  appBar: AppBar(title: Text("Advertisement")),
  body: Stack(
    children: [
      // 📦 Ads List
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : ads.isEmpty
              ? Center(child: Text("No ads available."))
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 100), // add space for buttons
                  itemCount: ads.length,
                  itemBuilder: (context, index) => AdCard(ad: ads[index]),
                ),

      // 🎯 Floating Buttons
      Positioned(
        bottom: 20,
        left: 140
        ,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyAdvertisementsScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.green.shade800,
            side: BorderSide(color: Colors.green.shade800, width: 1.5),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("My Ads", style: TextStyle(fontSize: 14)),
        ),
      ),
      Positioned(
        bottom: 20,
        right: 30,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateAdScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.shade800,
                width: 3.0,
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.add,
              color: Colors.green.shade800,
              size: 30,
            ),
          ),
        ),
      ),
    ],
  ),

  // Keep Bottom NavBar as is
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.language), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
    ],
  ),
);
  }
}