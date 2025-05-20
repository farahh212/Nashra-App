import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nashra_project2/screens/ad_details.dart';
import '../models/advertisement.dart';

class AdCard extends StatelessWidget {
  final Advertisement ad;

  const AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget imageWidget;

    if (ad.imageUrl != null && ad.imageUrl!.startsWith('/data/')) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(ad.imageUrl!),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
      );
    } else if (ad.imageUrl != null && ad.imageUrl!.startsWith('http')) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          ad.imageUrl!,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            width: double.infinity,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: Icon(Icons.broken_image, size: 40, color: isDark ? Colors.grey[400] : Colors.grey),
          ),
        ),
      );
    } else if (ad.imageUrl != null && ad.imageUrl!.startsWith('data:image/')) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          base64Decode(ad.imageUrl!.split(',').last),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
          width: double.infinity,
          color: isDark ? Colors.grey[800] : Colors.grey.shade200,
          child: Icon(Icons.image_not_supported, size: 40, color: isDark ? Colors.grey[400] : Colors.grey),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          const SizedBox(height: 12),
          Text(
            ad.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ad.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdDetailsPage(adId: ad.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Check Ad",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
