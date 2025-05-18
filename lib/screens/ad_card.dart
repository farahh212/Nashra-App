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
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(ad.imageUrl!), fit: BoxFit.contain),
      );
    } else if (ad.imageUrl != null && ad.imageUrl!.startsWith('http')) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(ad.imageUrl!, fit: BoxFit.contain),
      );
    } else if (ad.imageUrl != null && ad.imageUrl!.startsWith('data:image/')) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(base64Decode(ad.imageUrl!.split(',').last), fit: BoxFit.contain),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Placeholder(fallbackHeight: 200),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          SizedBox(height: 12),
          Text(ad.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 6),
          Text(ad.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.black54)),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Check Ad", style: TextStyle(fontSize: 13, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}