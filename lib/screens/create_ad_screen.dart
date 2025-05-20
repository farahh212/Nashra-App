import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class CreateAdScreen extends StatefulWidget {
  @override
  _CreateAdScreenState createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String? _imageUrl;
  bool _isLoading = false;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final newAd = Advertisement(
      id: '',
      title: _title,
      description: _description,
      imageUrl: _imageFile != null ? _imageFile!.path : null,
      status: AdvertisementStatus.pending,
      ownerId: Provider.of<AuthProvider>(context, listen: false).userId,
    );
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      await Provider.of<AdvertisementProvider>(context, listen: false).addAdvertisement(newAd, token);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Advertisement Submitted')));
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit advertisement')));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Advertisement",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Color(0xFF1976D2),
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Color(0xFF1976D2),
        ),
        backgroundColor: (isDark ? Colors.black : Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Title", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
              const SizedBox(height: 4),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter title...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              Text("Description", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
              const SizedBox(height: 4),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter description...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              Text("Image", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF1976D2)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: Center(
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                              SizedBox(height: 8),
                              Text("Select File", style: TextStyle(color: Colors.grey[600]))
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_imageFile!, fit: BoxFit.contain),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text("Accepted formats: JPG, PNG. Max size: 5MB", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
       bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}