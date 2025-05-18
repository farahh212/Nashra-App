import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewReportsPage extends StatefulWidget {
  final String searchQuery;

  const ViewReportsPage({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  _ViewReportsPageState createState() => _ViewReportsPageState();
}

class _ViewReportsPageState extends State<ViewReportsPage> {
  final Color _primaryGreen = const Color(0xFF81C784);
  final Color _backgroundGreen = const Color(0xFFF1F8E9);
  final Color _cardGreen = const Color(0xFFE8F5E9);
  final Color _titleGreen = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Reports',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: _primaryGreen,
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundGreen, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildReportsList(widget.searchQuery),
      ),
    );
  }

  Widget _buildReportsList(String searchQuery) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs.where((doc) {
          final title = doc['title']?.toString().toLowerCase() ?? '';
          final description = doc['description']?.toString().toLowerCase() ?? '';
          final createdAt = doc['createdAt']?.toString();
          
          return title.contains(searchQuery.toLowerCase()) ||
              description.contains(searchQuery.toLowerCase());
        }).toList();

        if (reports.isEmpty) {
          return Center(
            child: Text(
              'No reports found.',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[700]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final double? longitude = (report['longitude'] as num?)?.toDouble();
            final double? latitude = (report['latitude'] as num?)?.toDouble();

            return _buildReportTile(
              name: report['title'] ?? '',
              message: report['description'] ?? '',
              imageUrl: report['imageUrl'] ?? '',
              createdAt: report['createdAt'] ?? '',
              longitude: longitude,
              latitude: latitude,
              unread: false,
            );
          },
        );
      },
    );
  }

  Widget _buildReportTile({
    required String name,
    required String message,
    required String imageUrl,
    required String createdAt,
    required double? longitude,
    required double? latitude,
    required bool unread,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _cardGreen,
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InteractiveViewer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: _primaryGreen,
                child: const Icon(Icons.person, color: Colors.white),
              ),
        title: Text(
          name,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
              color: _titleGreen,
              fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.length > 60 ? '${message.substring(0, 60)}...' : message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(color: Colors.grey[800]),
            ),
            const SizedBox(height: 4),
            Text(
                'Created at: $createdAt',
                style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
            ),
            if (longitude != null && latitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: _primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      '($latitude, $longitude)',
                      style: GoogleFonts.lato(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    
                    TextButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open Maps.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Maps'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: _primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: unread
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            : null,
      ),
    );
  }
}
