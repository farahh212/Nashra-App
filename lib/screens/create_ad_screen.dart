import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';

class CreateAdScreen  extends StatefulWidget {

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
  Future<void> _pickImage()async{
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  Future<void>_submitForm()async{
    if(!_formKey.currentState!.validate()){
      return;
    }
    _formKey.currentState!.save();
    final newAd = Advertisement(
      id: '',
      title: _title,
      description: _description,
      imageUrl: _imageFile != null ? _imageFile!.path : null,
      status: AdvertisementStatus.pending,
    );
    try{
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      await Provider.of<AdvertisementProvider>(context,listen:false).addAdvertisement(newAd, token);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Advirtisement Submitted')));
      Navigator.of(context).pop();
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Failed to submit advertisement')));
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Advertisement"),
      ),
      body: Padding(padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Add Title :'),
            TextFormField(decoration: InputDecoration(
              hintText: 'Tile ...',
              border: OutlineInputBorder(),
            ),
            validator: (value)=> value!.isEmpty ? 'Please enter a title' : null,
            onSaved: (value)=>_title = value!,
            ),
            const SizedBox(height: 16),
            Text('Add Description :'),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Description ...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => _description = value!,
            ),
            const SizedBox(height: 16),
            Text('Add Image :'),
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
                              Text("Select file"),
                            ],
                          )
                        : Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
        ),
      ),
      )
    );
  }
}