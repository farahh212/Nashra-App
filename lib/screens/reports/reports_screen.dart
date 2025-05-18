import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../models/report.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';


class AllReports extends StatefulWidget {
    @override
    _AllReportsState createState() => _AllReportsState();
}

class _AllReportsState extends State<AllReports> {
    final _formKey = GlobalKey<FormState>();
    final _descController = TextEditingController();
    final List<String> _problemTypes = ['Road Damage', 'Street Light', 'Garbage', 'Water Leakage'];
    String? _selectedType;
    double? _latitude;
    double? _longitude;
    File? _imageFile;

    Future<void> _pickImage() async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);

        if (pickedFile != null) {
            setState(() {
                _imageFile = File(pickedFile.path);
            });
        }
    }


Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    // Navigate to MapScreen and pass the position
    _openMapScreen(position);

  } catch (e) {
    print('Error while getting location: $e');
  }
}


// Inside your reports screen after you get the location
void _openMapScreen(Position position) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MapScreen(initialPosition: LatLng(position.latitude, position.longitude))),
  );
}



    Future<String?> _uploadImage(File imageFile, String reportId) async {
        final ref = FirebaseStorage.instance.ref().child('report_images/$reportId.jpg');
        UploadTask uploadTask = ref.putFile(imageFile);

        TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
    }

Future<void> _submitReport() async {
  if (_formKey.currentState!.validate() && _latitude != null && _longitude != null) {
    final reportId = const Uuid().v4();

    // Upload image to Firebase Storage if exists
    String? imageUrl;
    if (_imageFile != null) {
      final ref = FirebaseStorage.instance.ref().child('report_images/$reportId.jpg');
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    final report = Report(
      id: reportId,
      title: _selectedType ?? 'Unknown',
      description: _descController.text.trim(),
      imageUrl: imageUrl,
      latitude: _latitude!,
      longitude: _longitude!,
      createdAt: DateTime.now(),
    );

    // Save report to Firestore
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .set(report.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Report submitted!')),
    );

    _formKey.currentState?.reset();
    setState(() {
      _selectedType = null;
      _imageFile = null;
      _latitude = null;
      _longitude = null;
      _descController.text = '';
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❗ Please complete all fields including location.')),
    );
  }
}


    @override
    void dispose() {
        _descController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Report A Problem')),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: ListView(
                        children: [
                            Text("Problem Type", style: TextStyle(fontWeight: FontWeight.bold)),
                            DropdownButtonFormField<String>(
                                value: _selectedType,
                                items: _problemTypes.map((type) {
                                    return DropdownMenuItem(value: type, child: Text(type));
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedType = val),
                                validator: (val) => val == null ? 'Select a type' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                                controller: _descController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    labelText: 'Describe the issue',
                                    border: OutlineInputBorder(),
                                ),
                                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                            ),
                            SizedBox(height: 16),
                            Text("Choose location", style: TextStyle(fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                                icon: Icon(Icons.location_pin),
                                label: Text(_latitude == null ? 'Get Location' : 'Location Selected'),
                                onPressed: _getCurrentLocation,
                            ),
                            if (_latitude != null && _longitude != null)
                                Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('Lat: $_latitude, Long: $_longitude'),
                                ),
                            SizedBox(height: 16),
                            Text("Upload a Photo", style: TextStyle(fontWeight: FontWeight.bold)),
                            GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                    height: 150,
                                    color: Colors.grey[200],
                                    child: _imageFile == null
                                            ? Center(child: Icon(Icons.add_a_photo, size: 40))
                                            : Image.file(_imageFile!, width: 300, height: 150, fit: BoxFit.cover),
                                ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                                onPressed: _submitReport,
                                child: Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}