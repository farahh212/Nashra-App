import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import '../providers/languageProvider.dart';

class CreateAdScreen extends StatefulWidget {
  @override
  _CreateAdScreenState createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  bool _isLoading = false;
  File? _imageFile;
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  String _titleErrorText = 'Please enter a title';
  String _descriptionErrorText = 'Please enter a description';

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;
    
    _titleErrorText = await _translateText('Please enter a title', currentLanguage);
    _descriptionErrorText = await _translateText('Please enter a description', currentLanguage);
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<String> _translateText(String text, String targetLang) async {
    if (_translations.containsKey('${text}_$targetLang')) {
      return _translations['${text}_$targetLang']!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations['${text}_$targetLang'] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;
    
    final successMessage = await _translateText('Advertisement Submitted', currentLanguage);
    final errorMessage = await _translateText('Failed to submit advertisement', currentLanguage);

    final newAd = Advertisement(
      id: '',
      title: _title,
      description: _description,
      imageUrl: _imageFile?.path,
      status: AdvertisementStatus.pending,
      ownerId: Provider.of<AuthProvider>(context, listen: false).userId,
    );
    
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      await Provider.of<AdvertisementProvider>(context, listen: false).addAdvertisement(newAd, token);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _translateText("Create Advertisement", currentLanguage),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? "Create Advertisement");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              FutureBuilder<String>(
                future: _translateText("Title", currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Title", 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])
                  );
                },
              ),
              const SizedBox(height: 4),
              FutureBuilder<String>(
                future: _translateText("Enter title...", currentLanguage),
                builder: (context, snapshot) {
                  return TextFormField(
                    decoration: InputDecoration(
                      hintText: snapshot.data ?? 'Enter title...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? _titleErrorText : null,
                    onSaved: (value) => _title = value!,
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: _translateText("Description", currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Description", 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])
                  );
                },
              ),
              const SizedBox(height: 4),
              FutureBuilder<String>(
                future: _translateText("Enter description...", currentLanguage),
                builder: (context, snapshot) {
                  return TextFormField(
                    decoration: InputDecoration(
                      hintText: snapshot.data ?? 'Enter description...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty ? _descriptionErrorText : null,
                    onSaved: (value) => _description = value!,
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: _translateText("Image", currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Image", 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])
                  );
                },
              ),
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
                              FutureBuilder<String>(
                                future: _translateText("Select File", currentLanguage),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? "Select File", 
                                    style: TextStyle(color: Colors.grey[600])
                                  );
                                },
                              )
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
              FutureBuilder<String>(
                future: _translateText("Accepted formats: JPG, PNG. Max size: 5MB", currentLanguage),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Accepted formats: JPG, PNG. Max size: 5MB", 
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<String>(
                future: _translateText("Submit", currentLanguage),
                builder: (context, snapshot) {
                  return ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(snapshot.data ?? 'Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}