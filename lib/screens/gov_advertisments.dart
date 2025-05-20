import 'package:flutter/material.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notificationService.dart';
import 'dart:io';
import 'package:translator/translator.dart'; // Add translator package
import '../providers/languageProvider.dart'; // Assuming you have a language provider

class GovernmentAdvertisementsScreen extends StatefulWidget {
  const GovernmentAdvertisementsScreen({super.key});

  @override
  _GovernmentAdvertisementsScreenState createState() =>
      _GovernmentAdvertisementsScreenState();
}

class _GovernmentAdvertisementsScreenState
    extends State<GovernmentAdvertisementsScreen> {
  AdvertisementStatus status = AdvertisementStatus.pending;
  late Future<List<Advertisement>> _adsFuture;
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};

  Future<String> _translateText(String text, String targetLang) async {
    if (_translations.containsKey('${text}_$targetLang')) {
      return _translations['${text}_$targetLang']!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations['${text}_$targetLang'] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdvertisementProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    _adsFuture = provider.getPendingAdvertisements(token);
  }

  Future<void> _loadAdvertisements() async {
    final provider = Provider.of<AdvertisementProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    switch (status) {
      case AdvertisementStatus.pending:
        _adsFuture = provider.getPendingAdvertisements(token);
        break;
      case AdvertisementStatus.approved:
        _adsFuture = provider.getApprovedAdvertisements(token);
        break;
      case AdvertisementStatus.rejected:
        _adsFuture = provider.getRejectedAdvertisements(token);
        break;
    }

    setState(() {});
  }

  Future<String?> getEmailByUid(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['email'];
    }
    return null;
  }

  Future<String?> getFcmTokenByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      return userDoc.data()['fcmToken'] as String?;
    }
    return null;
  }

  void _confirmAndDelete(String adId) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;
    
    final title = await _translateText("Delete Advertisement", currentLanguage);
    final content = await _translateText("Are you sure you want to delete this advertisement?", currentLanguage);
    final cancelText = await _translateText("Cancel", currentLanguage);
    final deleteText = await _translateText("Delete", currentLanguage);
    final successMessage = await _translateText("Advertisement deleted", currentLanguage);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(deleteText, style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final token = Provider.of<AuthProvider>(context, listen: false).token;
              await Provider.of<AdvertisementProvider>(context, listen: false)
                  .deleteAdvertisemnt(adId, token);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(successMessage)),
              );
              _loadAdvertisements();
            },
          ),
        ],
      ),
    );
  }

  void _updateStatus(String id, AdvertisementStatus newStatus) async {
    final provider = Provider.of<AdvertisementProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;

    await provider.updateAdvertisementStatus(id, newStatus, token);

    final adList = await _adsFuture;
    final updatedAd = adList.firstWhere((ad) => ad.id == id);
    final userEmail = await getEmailByUid(updatedAd.ownerId);
    final currentUserEmail = await getEmailByUid(auth.userId);

    if (userEmail != null) {
      final statusText = newStatus == AdvertisementStatus.approved 
          ? await _translateText("Approved", currentLanguage)
          : await _translateText("Rejected", currentLanguage);
          
      final notificationTitle = await _translateText(
          "Advertisement $statusText", currentLanguage);
      final notificationDescription = await _translateText(
          'Your advertisement "${updatedAd.title}" has been ${newStatus.name}.', 
          currentLanguage);

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': notificationTitle,
        'description': notificationDescription,
        'userEmail': userEmail,
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      final fcmToken = await getFcmTokenByEmail(userEmail);

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await sendPushNotification(
          fcmToken,
          notificationTitle,
          notificationDescription,
        );
      }
    }

    _loadAdvertisements();
  }

  Widget _buildFilterButton(AdvertisementStatus filterStatus, String label) {
    final isSelected = status == filterStatus;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          status = filterStatus;
        });
        _loadAdvertisements();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF1976D2) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Color(0xFF1976D2),
        side: BorderSide(color: Color(0xFF1976D2), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _translateText("Ads Approval", currentLanguage),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? "Ads Approval");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<String>(
                  future: _translateText("Pending", currentLanguage),
                  builder: (context, snapshot) {
                    return _buildFilterButton(
                      AdvertisementStatus.pending, 
                      snapshot.data ?? "Pending"
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: _translateText("Approved", currentLanguage),
                  builder: (context, snapshot) {
                    return _buildFilterButton(
                      AdvertisementStatus.approved, 
                      snapshot.data ?? "Approved"
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: _translateText("Rejected", currentLanguage),
                  builder: (context, snapshot) {
                    return _buildFilterButton(
                      AdvertisementStatus.rejected, 
                      snapshot.data ?? "Rejected"
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Advertisement>>(
                future: _adsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          FutureBuilder<String>(
                            future: _translateText(
                              "Loading advertisements...", 
                              currentLanguage
                            ),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Loading advertisements..."
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: FutureBuilder<String>(
                        future: _translateText(
                          "No advertisements found.", 
                          currentLanguage
                        ),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? "No advertisements found.");
                        },
                      ),
                    );
                  }

                  final ads = snapshot.data!;
                  return ListView.builder(
                    itemCount: ads.length,
                    itemBuilder: (ctx, i) {
                      final ad = ads[i];

                      final hasImage = ad.imageUrl != null && ad.imageUrl!.isNotEmpty;
                      final isLocal = hasImage && ad.imageUrl!.startsWith('/data/');
                      final isNetwork = hasImage && ad.imageUrl!.startsWith('http');

                      Widget imageWidget = Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: hasImage
                              ? isNetwork
                                  ? Image.network(
                                      ad.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                    )
                                  : isLocal
                                      ? Image.file(
                                          File(ad.imageUrl!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                        )
                                      : const Icon(Icons.image_not_supported)
                              : const Icon(Icons.image_not_supported),
                        ),
                      );

return Container(
  decoration: BoxDecoration(
    color: isDark ?const Color(0xFF1E1E1E): Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade300, width: 1.5),
  ),
  margin: const EdgeInsets.only(bottom: 12),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        imageWidget,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: _translateText(ad.title, currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? ad.title,
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 6),
              FutureBuilder<String>(
                future: _translateText(ad.description, currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? ad.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (status == AdvertisementStatus.pending) ...[
                      FutureBuilder<String>(
                        future: _translateText("Approve", currentLanguage),
                        builder: (context, snapshot) {
                          return TextButton(
                            onPressed: () =>
                                _updateStatus(ad.id, AdvertisementStatus.approved),
                            child: Text(snapshot.data ?? "Approve"),
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xFF1B5E20),
                            ),
                          );
                        },
                      ),
                      FutureBuilder<String>(
                        future: _translateText("Reject", currentLanguage),
                        builder: (context, snapshot) {
                          return TextButton(
                            onPressed: () =>
                                _updateStatus(ad.id, AdvertisementStatus.rejected),
                            child: Text(snapshot.data ?? "Reject"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                    ],
                    if (status == AdvertisementStatus.approved) ...[
                      const Spacer(),
                      FutureBuilder<String>(
                        future: _translateText("Delete", currentLanguage),
                        builder: (context, snapshot) {
                          return IconButton(
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                            tooltip: snapshot.data ?? "Delete",
                            onPressed: () => _confirmAndDelete(ad.id),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
