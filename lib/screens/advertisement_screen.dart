import 'package:flutter/material.dart';
import 'package:nashra_project2/models/index.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/screens/ad_card.dart';
import 'package:nashra_project2/screens/create_ad_screen.dart';
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

    // Delaying to ensure context is ready
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
        .advertisements // ✅ use a getter
        .where((ad) => ad.status == AdvertisementStatus.approved)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Advertisement")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ads.isEmpty
              ? Center(child: Text("No ads available."))
              : ListView.builder(
                  itemCount: ads.length,
                  itemBuilder: (context, index) => AdCard(ad: ads[index]),
                ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    // Navigate to the advertisement creation screen
    Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateAdScreen()));
  },
  backgroundColor: Colors.transparent, // Make background transparent
  elevation: 0, // Remove shadow
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.green.shade800, // Border color
        width: 3.0, // Border width
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
