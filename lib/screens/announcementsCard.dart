
// import 'package:flutter/material.dart';
// import 'package:nashra_project2/CitizenPages/commentSection.dart';
// import 'package:nashra_project2/models/announcement.dart';

// class Announcementcard extends StatefulWidget{
//   final Announcement announcement;
//   const Announcementcard({super.key, required this.announcement});

//   @override
//   State<Announcementcard> createState() => _AnnouncementcardState();
// }

// class _AnnouncementcardState extends State<Announcementcard> {
//   bool isLiked = false;
//   @override
//   Widget build(BuildContext context) {
    
//     return Card(
//       margin: const EdgeInsets.all(3.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       color: Color.fromARGB(255, 249, 251, 234),
//         child: Column(
//           children: [
//             Text(widget.announcement.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(widget.announcement.createdAt.toString(), style: TextStyle(fontSize: 14, color: Colors.grey)),
//             SizedBox(height: 10),
//             widget.announcement.imageUrl != null
//                 ? Image.network(widget.announcement.imageUrl!)
//                 : Container(), // Show image if available
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(widget.announcement.description, style: TextStyle(fontSize: 16)),
//             ),
//             SizedBox(height: 10),
            
//             Row(
//   mainAxisAlignment: MainAxisAlignment.end, // Align items to the start
//   children: [
//     IconButton(
//       icon: Icon(Icons.mode_comment_rounded),
//       onPressed: () {
       
//       },
//     ),
//     IconButton(
      
//       onPressed: () {
//       setState(() {
//     isLiked = !isLiked;

//   });
//       },
//       icon: Icon(Icons.thumb_up_off_alt_rounded, color: isLiked ? Colors.green.shade800 : const Color.fromARGB(255, 69, 68, 68)),
//     ),
//     SizedBox(width: 8), // Small space
    
//   ],
// )

//           ],
//         ),
      
      
//     );
//   }
// }