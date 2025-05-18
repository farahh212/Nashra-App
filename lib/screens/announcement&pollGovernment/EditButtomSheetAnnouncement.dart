import 'package:flutter/material.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Editbuttomsheetannouncement extends StatefulWidget {
  final Announcement announcement;

  const Editbuttomsheetannouncement({super.key, required this.announcement});

  @override
  State<Editbuttomsheetannouncement> createState() => _EditButtomsheetannouncementState();
}

class _EditButtomsheetannouncementState extends State<Editbuttomsheetannouncement> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController fileUrlController;

  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.announcement.title);
    descriptionController = TextEditingController(text: widget.announcement.description);
    fileUrlController = TextEditingController(text: widget.announcement.fileUrl ?? '');
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

  try {
    await announcementsProvider.editAnnouncement(
      widget.announcement.id,
      auth.token,
      auth.userId,
      newTitle: titleController.text.trim(),
      newDescription: descriptionController.text.trim(),
      newImageUrl: _imageFile != null ? _imageFile!.path : widget.announcement.imageUrl,
      newFileUrl: fileUrlController.text.trim().isEmpty ? null : fileUrlController.text.trim(),
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
            'Edit Announcement',
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
          TextField(
            controller: fileUrlController,
            decoration: InputDecoration(
              hintText: 'Paste file URL (e.g. Google Drive)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
          SizedBox(height: 10),
          Text('Edit Image:'),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Center(
                child: _imageFile == null
                    ? (widget.announcement.imageUrl != null
                        ? Image.network(widget.announcement.imageUrl!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, color: Colors.grey),
                              Text("Select image"),
                            ],
                          ))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: _editAnnouncement,
            child: Text('Update', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: Colors.green),
          )
        ],
      ),
    );
  }
}
