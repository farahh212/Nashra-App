import 'package:flutter/material.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';


class Buttomsheetannouncement extends StatefulWidget {
  @override
  State<Buttomsheetannouncement> createState() => ButtomsheetannouncementState();
}

class ButtomsheetannouncementState extends State<Buttomsheetannouncement> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final fileUrlController = TextEditingController();

  File? _imageFile;
  String? _imageUrl; // Add this to your state


  final ImagePicker _imagePicker = ImagePicker();
  List<String>? _pickedFilePaths;

// New method to pick files:
// Future<void> _pickFiles() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     allowMultiple: true, // or false if you want just one file
//     type: FileType.any,
//   );

//   if (result != null) {
//     setState(() {
//       _pickedFilePaths = result.paths.whereType<String>().toList();
//       // // Optionally, clear the fileUrlController.text if you no longer want URL input
//       // fileUrlController.clear();
//     });
//       print('Picked file paths: $_pickedFilePaths');
//   }
// }
Future<void> _pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.any,
  );

  if (result != null) {
    setState(() {
      _pickedFilePaths = result.paths.whereType<String>().toList();
    });
  }
}


Future<void> _uploadPickedFiles() async {
  if (_pickedFilePaths == null || _pickedFilePaths!.isEmpty) return;

  List<String> uploadedUrls = [];

  for (String path in _pickedFilePaths!) {
    File file = File(path);
    String fileName = path.split('/').last;

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('announcements')
        .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

    // Upload the file
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();

    uploadedUrls.add(downloadUrl);
  }

  // Now set the URLs for use in your announcement
  setState(() {
    _pickedFilePaths = uploadedUrls;
    
  });
}

void openFile(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open file')),
    );
  }
}


Future<void> _pickImages() async {
  final pickedFiles = await _imagePicker.pickMultiImage();
  if (pickedFiles != null && pickedFiles.isNotEmpty) {
    List<String> uploadedUrls = [];

    for (var pickedFile in pickedFiles) {
      File image = File(pickedFile.path);

      // Upload to Firebase Storage
      String fileName = pickedFile.path.split('/').last;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      uploadedUrls.add(downloadUrl);
    }

    setState(() {
      // If you want to keep the local File(s), you may need a list of Files as well
      // But for the frontend image displaying, you mainly need URLs:
      _imageUrl = uploadedUrls.join(','); // or keep as List<String> if preferred
    });
  }
}



Future<void> postAnnouncement() async {
  final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
  final auth = Provider.of<AuthProvider>(context, listen: false);

  try {
    // Upload files to Firebase Storage and get download URLs
    await _uploadPickedFiles();

    String? combinedFilePaths;
    if (_pickedFilePaths != null && _pickedFilePaths!.isNotEmpty) {
      combinedFilePaths = _pickedFilePaths!.join(','); // Join all URLs with commas
    } else if (fileUrlController.text.trim().isNotEmpty) {
      combinedFilePaths = fileUrlController.text.trim();
    }

    final newAnnouncement = Announcement(
      id: '',
      title: titleController.text,
      description: descriptionController.text,
      likes: 0,
      likedByUser: [],
      createdAt: DateTime.now(),
      imageUrl: _imageUrl,

 // (You can also upload this image similarly)
      fileUrl: combinedFilePaths,
      commentsNo: 0,
    );

    await announcementsProvider.addAnnouncement(newAnnouncement, auth.token);

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to post announcement: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFEFFF3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text(
            'Add Announcement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Announcement title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Announcement description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
SizedBox(height: 10),
GestureDetector(
  onTap: _pickFiles,
  child: Container(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(5),
      color: Colors.grey[200],
    ),
    child: _pickedFilePaths == null || _pickedFilePaths!.isEmpty
        ? Row(
            children: [
              Icon(Icons.attach_file, color: Colors.green),
              SizedBox(width: 8),
              Text('Tap to select files'),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _pickedFilePaths!
                .map((path) => GestureDetector(
                      onTap: () => openFile(path),
                      child: Text(
                        path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ))
                .toList(),
          ),
  ),
),

          SizedBox(height: 10),
          Text('Add Image:'),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Center(
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: Colors.grey),
                          Text("Select image"),
                        ],
                      )
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: postAnnouncement,
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}
