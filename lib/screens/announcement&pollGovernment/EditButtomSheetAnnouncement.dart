import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class Editbuttomsheetannouncement extends StatefulWidget {
  final Announcement announcement;

  const Editbuttomsheetannouncement({super.key, required this.announcement});

  @override
  State<Editbuttomsheetannouncement> createState() => _EditButtomsheetannouncementState();
}

class _EditButtomsheetannouncementState extends State<Editbuttomsheetannouncement> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  // late TextEditingController fileUrlController;
     final fileUrlController = TextEditingController();
   List<String>? _pickedFilePaths;
  

  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.announcement.title);
    descriptionController = TextEditingController(text: widget.announcement.description);
    // fileUrlController = TextEditingController(text: widget.announcement.fileUrl ?? '');
  }
  
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

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

 Future<void> _editAnnouncement() async {
  final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
  final auth = Provider.of<AuthProvider>(context, listen: false);
    await _uploadPickedFiles();
   

    String? combinedFilePaths;
    if (_pickedFilePaths != null && _pickedFilePaths!.isNotEmpty) {
      combinedFilePaths = _pickedFilePaths!.join(','); // Join all URLs with commas
    } else if (fileUrlController.text.trim().isNotEmpty) {
      combinedFilePaths = fileUrlController.text.trim();
    }

  try {
    await announcementsProvider.editAnnouncement(
      widget.announcement.id,
      auth.token,
      auth.userId,
      newTitle: titleController.text.trim(),
      newDescription: descriptionController.text.trim(),
      newImageUrl: _imageFile != null ? _imageFile!.path : widget.announcement.imageUrl,
      newFileUrl: combinedFilePaths,
    );

    Navigator.pop(context); // Close the bottom sheet
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update announcement: ${e.toString()}')),
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
        color: theme.scaffoldBackgroundColor,
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
                'Edit Announcement',
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
            child:        GestureDetector(
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
          ),
          const SizedBox(height: 20),
          Text(
            'Edit Image:',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
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
                    ? (widget.announcement.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.announcement.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: primaryColor),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
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
                          ))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _editAnnouncement,
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
              'Update',
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
