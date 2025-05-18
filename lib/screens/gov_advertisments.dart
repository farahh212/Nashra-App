import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';

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
    Future.microtask(() => _loadAdvertisements());
  }

  void _loadAdvertisements() {
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
    setState(() {}); // trigger UI rebuild after loading ads
  }

  void _updateStatus(String id, AdvertisementStatus newStatus) async {
    final provider = Provider.of<AdvertisementProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    await provider.updateAdvertisementStatus(id, newStatus, token);
    _loadAdvertisements();
  }

  Widget _buildFilterButton(AdvertisementStatus filterStatus, String label) {
    final isSelected = status == filterStatus;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          status = filterStatus;
          _loadAdvertisements();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.green,
        side: BorderSide(color: Colors.green, width: 2),
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
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ad.title,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(ad.description),
                              if (status == AdvertisementStatus.pending)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => _updateStatus(
                                          ad.id, AdvertisementStatus.approved),
                                      child: Text('Approve'),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.green),
                                    ),
                                    TextButton(
                                      onPressed: () => _updateStatus(
                                          ad.id, AdvertisementStatus.rejected),
                                      child: Text('Reject'),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                    ),
                                  ],
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
    );
  }
}
