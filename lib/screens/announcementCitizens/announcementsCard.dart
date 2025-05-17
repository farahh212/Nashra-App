
import 'package:flutter/material.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/EditButtomSheetAnnouncement.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:nashra_project2/CitizenPages/commentSection.dart';
// import 'package:nashra_project2/CitizenPages/commentsFetched.dart';
import './commentsFetched.dart';

import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Announcementcard extends StatefulWidget{
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
    final isAdmin =auth.isAdmin;
    
    return Card(
      margin: const EdgeInsets.all(3.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Color.fromARGB(255, 249, 251, 234),
        child: Column(
          children: [
            Text(widget.announcement.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if(isAdmin)
            IconButton(onPressed: (){
              announcementsProvider.removeAnnouncement(widget.announcement.id, auth.token, auth.userId);

            }, icon: Icon(Icons.delete)),
    if (isAdmin)
      IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Allows the sheet to take full height
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.50,
              child: Editbuttomsheetannouncement(announcement: widget.announcement), // Make sure this class/widget exists and is correctly named
            ),
          );
        },
        icon: Icon(Icons.edit),
      ),
            
            Text(widget.announcement.createdAt.toString(), style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),
            widget.announcement.fileUrl != null && widget.announcement.fileUrl!.isNotEmpty
  ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          final Uri url = Uri.parse(widget.announcement.fileUrl!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open the file')),
            );
          }
        },
        icon: Icon(Icons.attach_file),
        label: Text("View Attached File"),
        // style: ElevatedButton.styleFrom(
        //   backgroundColor:Color.fromARGB(255, 249, 251, 234),
        //   foregroundColor: Colors.white,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // ),
      ),
    )
  : Container(),
 // Show image if available
            SizedBox(height: 10),
            widget.announcement.fileUrl != null? SfPdfViewer.network(widget.announcement.fileUrl!): 
            Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.announcement.description, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            
            Row(
  mainAxisAlignment: MainAxisAlignment.end, // Align items to the start
  children: [
    IconButton(
      icon: Icon(Icons.mode_comment_rounded),
      onPressed: () {
        showModalBottomSheet(
          
          
      context: context,
      isScrollControlled: true, // Allows the sheet to take full height
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.50,
        child: Padding(
          
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Account for keyboard
          ),
          child: Commentsfetched(announcement: widget.announcement),
        ),
      ),
    );
       
       
      },
    ),
    
  if (!isAdmin)
    IconButton(
      onPressed: () {
        setState(() {
          isLiked = !isLiked;
          if (isLiked) {
            announcementsProvider.addLikeToAnnouncement(widget.announcement.id, auth.token, auth.userId);
          } else {
            announcementsProvider.removeLikeFromAnnouncement(widget.announcement.id, auth.token, auth.userId);
          }
        });
      },
      icon: Icon(Icons.thumb_up_off_alt_rounded, color: isLiked ? Colors.green.shade800 : const Color.fromARGB(255, 69, 68, 68)),
    ),

    if(!isAdmin)
    Text(
      widget.announcement.likes.toString(),
      style: TextStyle(
        fontSize: 16,
        color: isLiked ? Colors.green.shade800 : const Color.fromARGB(255, 69, 68, 68),
      ),
    ),
    SizedBox(width: 8), // Small space
    
  ],
)

          ],
        ),
      
      
    );
  }
}