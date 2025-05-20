import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class AdDetailsPage extends StatefulWidget {
  final String adId;

  const AdDetailsPage({required this.adId, Key? key}) : super(key: key);

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  Advertisement? ad;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    Provider.of<AdvertisementProvider>(context, listen: false)
        .getAdvertisementById(widget.adId, token)
        .then((fetchedAd) {
      setState(() {
        ad = fetchedAd;
        _isLoading = false;
      });
    });
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    if (url.startsWith('/data/')) {
      return Image.file(File(url), fit: BoxFit.cover, width: double.infinity);
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      );
    } else if (url.startsWith('data:image/')) {
      return Image.memory(
        base64Decode(url.split(',').last),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Advertisement Details")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ad == null
              ? const Center(child: Text("Ad not found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildImage(ad!.imageUrl),
                      const SizedBox(height: 24),
                      Text(
                        ad!.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                 bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
