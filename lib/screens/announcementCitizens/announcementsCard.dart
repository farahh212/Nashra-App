import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/EditButtomSheetAnnouncement.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import './commentsFetched.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import '../../providers/languageProvider.dart';

class Announcementcard extends StatefulWidget {
  final Announcement announcement;
  const Announcementcard({super.key, required this.announcement});

  @override
  State<Announcementcard> createState() => _AnnouncementcardState();
}

class _AnnouncementcardState extends State<Announcementcard> {
  late Future<void> _announcementsFuture;
  bool isLiked = false;
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  String _deleteTooltip = 'Delete Announcement';
  String _editTooltip = 'Edit Announcement';
  String _viewCommentsTooltip = 'View Comments';
  String _likeTooltip = 'Like';

  Future<String> _translateText(String text, String targetLang) async {
    final key = '${text}_$targetLang';
    if (_translations.containsKey(key)) {
      return _translations[key]!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations[key] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
    _announcementsFuture = announcementsProvider.fetchAnnouncementsFromServer(auth.token);
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;
    
    _deleteTooltip = await _translateText('Delete Announcement', currentLang);
    _editTooltip = await _translateText('Edit Announcement', currentLang);
    _viewCommentsTooltip = await _translateText('View Comments', currentLang);
    _likeTooltip = await _translateText('Like', currentLang);
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcementsProvider = Provider.of<Announcementsprovider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLanguageCode;

    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: isDark ? 2 : 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FutureBuilder<String>(
                    future: _translateText(widget.announcement.title, currentLang),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? widget.announcement.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(
                    onPressed: () {
                      announcementsProvider.removeAnnouncement(
                        widget.announcement.id,
                        auth.token,
                        auth.userId,
                      );
                    },
                    icon: Icon(Icons.delete, color: primaryColor),
                    tooltip: _deleteTooltip,
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Container(
                          height: MediaQuery.of(context).size.height * 0.50,
                          child: Editbuttomsheetannouncement(announcement: widget.announcement),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit, color: primaryColor),
                    tooltip: _editTooltip,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),

            Text(
              widget.announcement.createdAt.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 12),

            if (widget.announcement.imageUrl != null &&
                widget.announcement.imageUrl!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.announcement.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _translateText('Failed to load image', currentLang),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Failed to load image',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (widget.announcement.fileUrl != null &&
                widget.announcement.fileUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: FutureBuilder<String>(
                              future: _translateText('View Attachment', currentLang),
                              builder: (context, snapshot) {
                                return Text(snapshot.data ?? 'View Attachment');
                              },
                            ),
                            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                            iconTheme: IconThemeData(color: primaryColor),
                            elevation: 0,
                          ),
                          body: SfPdfViewer.network(widget.announcement.fileUrl!),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.attach_file, color: Colors.white),
                  label: FutureBuilder<String>(
                    future: _translateText('View Attached File', currentLang),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? 'View Attached File');
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: FutureBuilder<String>(
                future: _translateText(widget.announcement.description, currentLang),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? widget.announcement.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[300] : Colors.black87,
                      height: 1.5,
                    ),
                  );
                },
              ),
            ),

            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.mode_comment_rounded,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height * 1,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: CommentsFetched(announcement: widget.announcement),
                      ),
                    );
                  },
                  tooltip: _viewCommentsTooltip,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.announcement.commentsNo ?? 0}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 20),

                if (!isAdmin) ...[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                        if (isLiked) {
                          announcementsProvider.addLikeToAnnouncement(
                              widget.announcement.id, auth.token, auth.userId);
                        } else {
                          announcementsProvider.removeLikeFromAnnouncement(
                              widget.announcement.id, auth.token, auth.userId);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.thumb_up_off_alt_rounded,
                      color: widget.announcement.likedByUser.contains(auth.userId) ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    tooltip: _likeTooltip,
                  ),
                  Text(
                    widget.announcement.likes.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isLiked ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
