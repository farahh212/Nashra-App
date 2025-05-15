import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/advertisement.dart';

class AdCard extends StatelessWidget {
  final Advertisement ad;

  const AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (ad.imageUrl != null && ad.imageUrl!.startsWith('/data/')) {
      imageWidget = Image.file(File(ad.imageUrl!));
    } else if (ad.imageUrl != null && ad.imageUrl!.startsWith('http')) {
      imageWidget = Image.network(ad.imageUrl!);
    } else if (ad.imageUrl != null && ad.imageUrl!.startsWith('data:image/')) {
      imageWidget = Image.memory(base64Decode(ad.imageUrl!.split(',').last));
    } else {
      imageWidget = Placeholder(fallbackHeight: 200);
    }

    return Card(
      margin: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
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
