import 'package:flutter/material.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notificationService.dart';
import 'dart:io';

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
  void _confirmAndDelete(String adId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Delete Advertisement"),
      content: const Text("Are you sure you want to delete this advertisement?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        TextButton(
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
          onPressed: () async {
            Navigator.of(ctx).pop();
            final token = Provider.of<AuthProvider>(context, listen: false).token;
            await Provider.of<AdvertisementProvider>(context, listen: false)
                .deleteAdvertisemnt(adId, token);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Advertisement deleted")),
            );
            _loadAdvertisements();
          },
        ),
      ],
    ),
  );
}


  void _updateStatus(String id, AdvertisementStatus newStatus) async {
    final provider =
        Provider.of<AdvertisementProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;

    await provider.updateAdvertisementStatus(id, newStatus, token);

    final adList = await _adsFuture;
    final updatedAd = adList.firstWhere((ad) => ad.id == id);
    final userEmail = await getEmailByUid(updatedAd.ownerId);
    final currentUserEmail = await getEmailByUid(auth.userId);

    if (userEmail != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title':
            'Advertisement ${newStatus == AdvertisementStatus.approved ? "Approved" : "Rejected"}',
        'description':
            'Your advertisement "${updatedAd.title}" has been ${newStatus.name}.',
        'userEmail': userEmail,
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      final fcmToken = await getFcmTokenByEmail(userEmail);

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await sendPushNotification(
          fcmToken,
          'Advertisement ${newStatus == AdvertisementStatus.approved ? "Approved" : "Rejected"}',
          'Your ad "${updatedAd.title}" has been ${newStatus.name}.',
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
    return Scaffold(
      appBar: AppBar(title: Text("Ads Approval")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton(AdvertisementStatus.pending, 'Pending'),
                _buildFilterButton(AdvertisementStatus.approved, 'Approved'),
                _buildFilterButton(AdvertisementStatus.rejected, 'Rejected'),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Advertisement>>(
                future: _adsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return Center(child: Text("No advertisements found."));

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
                          color: Colors.white,
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
                                    Text(
                                      ad.title,
                                      style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ad.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                   Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Row(
    children: [
      if (status == AdvertisementStatus.pending) ...[
        TextButton(
          onPressed: () => _updateStatus(ad.id, AdvertisementStatus.approved),
          child: const Text('Approve'),
          style: TextButton.styleFrom(foregroundColor: Color(0xFF1B5E20)),
        ),
        TextButton(
          onPressed: () => _updateStatus(ad.id, AdvertisementStatus.rejected),
          child: const Text('Reject'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
      if (status == AdvertisementStatus.approved) ...[
        const Spacer(),
        IconButton(
          icon: Icon(Icons.delete_forever, color: Colors.red),
          tooltip: 'Delete',
          onPressed: () => _confirmAndDelete(ad.id),
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
