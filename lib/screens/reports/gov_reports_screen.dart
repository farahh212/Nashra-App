import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../Sidebars/CitizenSidebar.dart';
import '../../providers/languageProvider.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewReportsPage extends StatefulWidget {
  final String searchQuery;

  const ViewReportsPage({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  _ViewReportsPageState createState() => _ViewReportsPageState();
}

class _ViewReportsPageState extends State<ViewReportsPage> {
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

  bool get isDark {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;
    final Color lightBlue = Colors.blue.shade50;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CitizenSidebar(),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      appBar: AppBar(
      
        backgroundColor: (isDark ? Colors.black : Colors.white),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Color(0xFF1976D2),
        ),
        elevation: 0,
        title: FutureBuilder<String>(
          future: _translateText('View Reports', currentLanguage),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'View Reports',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                letterSpacing: 1.2,
              ),
            );
          },
        ),
       
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [lightBlue, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildReportsList(widget.searchQuery, Theme.of(context), isDark, currentLanguage),
      ),
    );
  }

  Widget _buildReportsList(String searchQuery, ThemeData theme, bool isDark, String currentLanguage) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs.where((doc) {
          final title = doc['title']?.toString().toLowerCase() ?? '';
          final description = doc['description']?.toString().toLowerCase() ?? '';
          return title.contains(searchQuery.toLowerCase()) ||
              description.contains(searchQuery.toLowerCase());
        }).toList();

        reports.sort((a, b) {
          final aRead = (a['read'] ?? false) as bool;
          final bRead = (b['read'] ?? false) as bool;
          if (aRead == bRead) return 0;
          return aRead ? 1 : -1;
        });

        if (reports.isEmpty) {
          return FutureBuilder<String>(
            future: _translateText('No reports found.', currentLanguage),
            builder: (context, snapshot) {
              return Center(
                child: Text(
                  snapshot.data ?? 'No reports found.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    color: theme.hintColor.withOpacity(isDark ? 0.7 : 1),
                  ),
                ),
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final double? longitude = (report['longitude'] as num?)?.toDouble();
            final double? latitude = (report['latitude'] as num?)?.toDouble();
            final bool isRead = (report['read'] ?? false) as bool;

            return _buildReportTile(
              docId: report.id,
              name: report['title'] ?? '',
              message: report['description'] ?? '',
              imageUrl: report['imageUrl'] ?? '',
              createdAt: report['createdAt'] ?? '',
              longitude: longitude,
              latitude: latitude,
              unread: !isRead,
              isRead: isRead,
              theme: theme,
              isDark: isDark,
              currentLanguage: currentLanguage,
            );
          },
        );
      },
    );
  }

  Widget _buildReportTile({
    required String docId,
    required String name,
    required String message,
    required String imageUrl,
    required String createdAt,
    required double? longitude,
    required double? latitude,
    required bool unread,
    required bool isRead,
    required ThemeData theme,
    required bool isDark,
    required String currentLanguage,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isRead
                ? Colors.green.withOpacity(0.10)
                : Colors.red.withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isRead ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.92)
            : Colors.white.withOpacity(0.98),
        elevation: isDark ? 2 : 6,
        shadowColor: isDark ? Colors.black54 : Colors.blueGrey[100],
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      imageUrl.isNotEmpty
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
                              child: Hero(
                                tag: imageUrl + docId,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/placeholder.png',
                                    image: imageUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: isDark
                                  ? theme.primaryColor.withOpacity(0.7)
                                  : theme.primaryColor.withOpacity(0.85),
                              child: const Icon(Icons.person, color: Colors.white, size: 32),
                              radius: 32,
                            ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: _translateText(name, currentLanguage),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.97)
                                        : theme.textTheme.titleLarge?.color,
                                    fontSize: 20,
                                    letterSpacing: 0.5,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<String>(
                              future: _translateText(
                                  message.length > 70
                                      ? '${message.substring(0, 70)}...'
                                      : message,
                                  currentLanguage),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ??
                                      (message.length > 70
                                          ? '${message.substring(0, 70)}...'
                                          : message),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white70
                                        : theme.textTheme.bodyMedium?.color
                                            ?.withOpacity(0.95),
                                    height: 1.3,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 17, color: theme.primaryColor.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      FutureBuilder<String>(
                        future: _translateText('Created at: ', currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            '${snapshot.data ?? 'Created at: '} ${DateTime.tryParse(createdAt)?.toLocal().toString().substring(0, 16) ?? createdAt}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: theme.hintColor.withOpacity(isDark ? 0.8 : 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FutureBuilder<String>(
                        future: _translateText('Mark as read', currentLanguage),
                        builder: (context, snapshot) {
                          return Tooltip(
                            message: snapshot.data ?? 'Mark as read',
                            child: Checkbox(
                              value: isRead,
                              onChanged: (value) async {
                                await FirebaseFirestore.instance
                                    .collection('reports')
                                    .doc(docId)
                                    .update({'read': value});
                              },
                              activeColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _translateText('Mark as read', currentLanguage),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Mark as read',
                            style: TextStyle(
                              color: isRead ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),

                    ],
                  ),
                  if (longitude != null && latitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 18, color: theme.primaryColor.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FutureBuilder<String>(
                              future: _translateText('Maps', currentLanguage),
                              builder: (context, snapshot) {
                                return TextButton.icon(
                                  onPressed: () async {
                                    final uri = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      final errorMsg = await _translateText(
                                          'Could not open Maps.', currentLanguage);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(errorMsg)),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.map, size: 20),
                                  label: Text(snapshot.data ?? 'Maps'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: theme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // Read/Unread mark at top right
              Positioned(
                top: 0,
                right: 0,
                child: unread
                    ? Tooltip(
                        message: 'Unread',
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    : Tooltip(
                        message: 'Read',
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
