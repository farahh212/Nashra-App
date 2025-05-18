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

  // Collect options from your UI - assuming you have a list of option strings, e.g. optionsList
List<String> optionsList = optionControllers
    .map((controller) => controller.text.trim())
    .where((option) => option.isNotEmpty)
    .toList();
 // Implement this based on your UI

  if (questionController.text.isEmpty || optionsList.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please add a question and at least 2 options')),
    );
    return;
  }

  try {
    final newPoll = Poll(
      id: '', // Firebase will generate this
      question: questionController.text.trim(),
      options: optionsList,
      votes: {}, // start empty
      voterToOption: {}, // start empty
      createdAt: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 7)), // example end date, adjust as needed
      imageUrl: _imageFile != null ? _imageFile!.path : null,
      commentsNo: 0,
    );

    await pollsProvider.addPoll(newPoll, auth.token);

    Navigator.pop(context); // Close bottom sheet on success
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to post poll: ${e.toString()}')),
    );
  }
}


  // Dispose controllers to avoid memory leaks
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
            'Add Poll',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: questionController,
            decoration: InputDecoration(
              hintText: 'Add question here',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
          SizedBox(height: 10),

          // Render option textfields dynamically
          ...optionControllers.asMap().entries.map((entry) {
            int idx = entry.key;
            TextEditingController controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Option ${idx + 1}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  suffixIcon: optionControllers.length > 2 ? IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
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
              icon: Icon(Icons.add),
              label: Text('Add Option'),
              onPressed: () {
                setState(() {
                  optionControllers.add(TextEditingController());
                });
              },
            ),
          ),

          SizedBox(height: 10),
          Text('Add Image:'),
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
            onPressed: () {
              postPoll();

              // Pollsprovider.addPoll();
              // Collect question and options here and handle submit logic
              final question = questionController.text.trim();
              final options = optionControllers
                  .map((controller) => controller.text.trim())
                  .where((option) => option.isNotEmpty)
                  .toList();

              if (question.isEmpty || options.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a question and at least 2 options')),
                );
                return;
              }

              // You can now send question, options, and _imageFile to your provider to save
              print('Question: $question');
              print('Options: $options');
              // Add your post poll logic here
            },
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              
            ),
          ),
        ],
      ),
    );
  }
}
