import 'package:flutter/material.dart';
import '../models/advertisement.dart';

class AdCard extends StatelessWidget {
  final Advertisement ad;

  const AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ad.imageUrl != ''
              ? Image.network(ad.imageUrl)
              : Placeholder(fallbackHeight: 200),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad.title, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(ad.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
