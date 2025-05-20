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


  // final ImagePicker _imagePicker = ImagePicker();
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

Future<void> _uploadImage() async {
  if (_imageFile == null) return;

  try {
    // Create a reference to the location you want to upload to in Firebase Storage
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('announcement_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the file
    UploadTask uploadTask = ref.putFile(_imageFile!);
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      _imageUrl = downloadUrl;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
    );
  }
}
Future<void> _pickImages() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      _imageFile = File(pickedFile.path);
    });
    // Upload the image immediately after picking
    await _uploadImage();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Announcement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: TextField(
              controller: titleController,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Announcement title',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: TextField(
              controller: descriptionController,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Announcement description',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickFiles,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: _pickedFilePaths == null || _pickedFilePaths!.isEmpty
                  ? Row(
                      children: [
                        Icon(Icons.attach_file, color: primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Tap to select files',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _pickedFilePaths!
                          .map((path) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: GestureDetector(
                                  onTap: () => openFile(path),
                                  child: Row(
                                    children: [
                                      Icon(Icons.insert_drive_file, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          path.split('/').last,
                                          style: TextStyle(
                                            color: primaryColor,
                                            decoration: TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add Image:',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImages,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: primaryColor, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            "Select image",
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: postAnnouncement,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isDark ? 0 : 2,
            ),
            child: const Text(
              'Post',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
