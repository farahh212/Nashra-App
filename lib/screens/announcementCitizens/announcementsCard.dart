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
    final darkGreen = Colors.green.shade800;

    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      elevation: 3,
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    icon: Icon(Icons.delete, color:  Colors.grey),
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
                    icon: Icon(Icons.edit, color: Colors.grey),
                    tooltip: 'Edit Announcement',
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),

            Text(
              widget.announcement.createdAt.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 12),

            // Attached file button
            if (widget.announcement.fileUrl != null && widget.announcement.fileUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('View Attachment')),
        body: SfPdfViewer.network(widget.announcement.fileUrl!),
      ),
    ),
  );
},

                  icon: Icon(Icons.attach_file, color: Colors.white),
                  label: const Text("View Attached File"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

            // PDF viewer if fileUrl exists
            if (widget.announcement.fileUrl != null)
              SizedBox(
                height: 200,
                child: SfPdfViewer.network(widget.announcement.fileUrl!),
              ),

            const SizedBox(height: 12),

            Text(
              widget.announcement.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Comment and Like row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.mode_comment_rounded, color: darkGreen),
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
                    color: darkGreen,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 20),

                if (!isAdmin)
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
                      color: isLiked ? darkGreen : Colors.grey[700],
                    ),
                    tooltip: 'Like',
                  ),

                if (!isAdmin)
                  Text(
                    widget.announcement.likes.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isLiked ? darkGreen : Colors.grey[700],
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
