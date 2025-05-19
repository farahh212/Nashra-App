import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/EditButtomSheetAnnouncement.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import './commentsFetched.dart';

import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';

class Announcementcard extends StatefulWidget {
  final Announcement announcement;
  const Announcementcard({super.key, required this.announcement});

  @override
  State<Announcementcard> createState() => _AnnouncementcardState();
}

class _AnnouncementcardState extends State<Announcementcard> {
  late Future<void> _announcementsFuture;
  bool isLiked = false;

  bool isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
    _announcementsFuture = announcementsProvider.fetchAnnouncementsFromServer(auth.token);
  }

  @override
  Widget build(BuildContext context) {
    final announcementsProvider = Provider.of<Announcementsprovider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);

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
            // Title and admin actions row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.announcement.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
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
                    tooltip: 'Delete Announcement',
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
                    tooltip: 'Edit Announcement',
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
                widget.announcement.imageUrl!.isNotEmpty &&
                isImageUrl(widget.announcement.imageUrl!))
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
                          Text(
                            "Failed to load image",
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // If the file is not an image (e.g., PDF), show a button to open it
            if (widget.announcement.fileUrl != null &&
                widget.announcement.fileUrl!.isNotEmpty &&
                !isImageUrl(widget.announcement.fileUrl!))
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text('View Attachment'),
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
                  label: const Text("View Attached File"),
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
              child: Text(
                widget.announcement.description,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),

            // Comment and Like row
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
                        height: MediaQuery.of(context).size.height * 0.50,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: CommentsFetched(announcement: widget.announcement),
                      ),
                    );
                  },
                  tooltip: 'View Comments',
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
                      color: isLiked ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    tooltip: 'Like',
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
