import 'package:flutter/material.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/models/poll.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Buttomsheetpolls extends StatefulWidget {
  @override
  State<Buttomsheetpolls> createState() => ButtomsheetpollsState();
}

// class ButtomsheetpollsState extends State<Buttomsheetpolls> {
class ButtomsheetpollsState extends State<Buttomsheetpolls> {
  final questionController = TextEditingController();
  
  // List of controllers for options, start with 2 controllers:
  List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> postPoll() async {
    final pollsProvider = Provider.of<Pollsprovider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    List<String> optionsList = optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (questionController.text.isEmpty || optionsList.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a question and at least 2 options')),
      );
      return;
    }

    try {
      final newPoll = Poll(
        id: '',
        question: questionController.text.trim(),
        options: optionsList,
        votes: {},
        voterToOption: {},
        createdAt: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        imageUrl: _imageFile != null ? _imageFile!.path : null,
        commentsNo: 0,
      );

      await pollsProvider.addPoll(newPoll, auth.token);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post poll: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(16),
      child: ListView(
    
        shrinkWrap: true,
        children: [
          Text(
            'Add Poll',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: questionController,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Add question here',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : Colors.white,
            ),
          ),
          SizedBox(height: 10),

          ...optionControllers.asMap().entries.map((entry) {
            int idx = entry.key;
            TextEditingController controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Option ${idx + 1}',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  suffixIcon: optionControllers.length > 2 ? IconButton(
                    icon: Icon(Icons.remove_circle, 
                      color: isDark ? Colors.red[300] : Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        optionControllers.removeAt(idx).dispose();
                      });
                    },
                  ) : null,
                ),
              ),
            );
          }),

          // Plus button to add more options
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(Icons.add, color: primaryColor),
              label: Text(
                'Add Option',
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () {
                setState(() {
                  optionControllers.add(TextEditingController());
                });
              },
            ),
          ),

          SizedBox(height: 10),
          Text(
            'Add Image:',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey[850] : Colors.grey[100],
              ),
              child: Center(
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Select image",
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: postPoll,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Post Poll',
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
