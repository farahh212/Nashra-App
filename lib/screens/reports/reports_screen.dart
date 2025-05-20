import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';

import '../../models/report.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../Sidebars/CitizenSidebar.dart';
import '../../providers/languageProvider.dart';
import '../../utils/theme.dart';



class AllReports extends StatefulWidget {
  @override
  _AllReportsState createState() => _AllReportsState();
}

class _AllReportsState extends State<AllReports> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _otherTypeController = TextEditingController();
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};

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

  bool get isDark {
    return Theme.of(context).brightness == Brightness.dark;
  }

  final List<String> _problemTypes = [
    'Road Damage',
    'Street Light',
    'Garbage',
    'Water Leakage',
    'Sewage Pipes',
    'Traffic Congestion',
    'Blocked Drain',
    'Noise Complaint',
    'Broken Sign',
    'Quality Control',
    'Other'
  ];

  String? _selectedType;
  double? _latitude;
  double? _longitude;
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectLocationOnMap() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialPosition: LatLng(26.8206, 30.8025),
          initialZoom: 5.5,
        ),
      ),
    );

    if (pickedLocation != null) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final currentLanguage = languageProvider.currentLanguageCode;
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => FutureBuilder<List<String>>(
          future: Future.wait([
            _translateText('Confirm Location', currentLanguage),
            _translateText('Latitude', currentLanguage),
            _translateText('Longitude', currentLanguage),
            _translateText('Do you want to use this location?', currentLanguage),
            _translateText('Cancel', currentLanguage),
            _translateText('Confirm', currentLanguage),
          ]),
          builder: (context, snapshot) {
            final tr = snapshot.data;
            return AlertDialog(
              title: Text(tr?[0] ?? 'Confirm Location'),
              content: Text(
                  '${tr?[1] ?? 'Latitude'}: ${pickedLocation.latitude.toStringAsFixed(5)}\n'
                  '${tr?[2] ?? 'Longitude'}: ${pickedLocation.longitude.toStringAsFixed(5)}\n\n'
                  '${tr?[3] ?? 'Do you want to use this location?'}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(tr?[4] ?? 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(tr?[5] ?? 'Confirm'),
                ),
              ],
            );
          },
        ),
      );

      if (confirmed == true) {
        setState(() {
          _latitude = pickedLocation.latitude;
          _longitude = pickedLocation.longitude;
        });
      }
    }
  }

  Future<String> _getTranslatedProblemType(String type, String lang) async {
    return await _translateText(type, lang);
  }

  Future<void> _submitReport() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;

    if (_formKey.currentState!.validate() && _latitude != null && _longitude != null) {
      final reportId = const Uuid().v4();

      String? imageUrl;
      if (_imageFile != null) {
        final ref =
            FirebaseStorage.instance.ref().child('report_images/$reportId.jpg');
        final uploadTask = ref.putFile(_imageFile!);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final report = Report(
        id: reportId,
        title: _selectedType == 'Other'
            ? _otherTypeController.text.trim()
            : _selectedType ?? 'Unknown',
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        latitude: _latitude!,
        longitude: _longitude!,
        createdAt: DateTime.now(),
        read: false,
      );

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .set(report.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FutureBuilder<String>(
            future: _translateText('✅ Report submitted!', currentLanguage),
            builder: (context, snapshot) =>
                Text(snapshot.data ?? '✅ Report submitted!'),
          ),
        ),
      );

      _formKey.currentState?.reset();
      setState(() {
        _selectedType = null;
        _imageFile = null;
        _latitude = null;
        _longitude = null;
        _descController.clear();
        _otherTypeController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FutureBuilder<String>(
            future: _translateText('❗ Please complete all fields including location.', currentLanguage),
            builder: (context, snapshot) =>
                Text(snapshot.data ?? '❗ Please complete all fields including location.'),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _otherTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade700;
    final Color lightBlue = Colors.blue.shade50;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: (isDark ? Colors.black : Colors.white),
        iconTheme: IconThemeData(
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
        elevation: 0,
        title: FutureBuilder<String>(
          future: _translateText('Report a Problem', currentLanguage),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Report a Problem',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            );
          },
        ),
        // iconTheme: IconThemeData(
        //   color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        // ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: Container(
        color: isDark ? Colors.black : lightBlue,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    FutureBuilder<String>(
                      future: _translateText('Problem Type', currentLanguage),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Problem Type',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ),
                    FutureBuilder<List<String>>(
                      future: Future.wait(_problemTypes.map((type) => _translateText(type, currentLanguage)).toList()),
                      builder: (context, snapshot) {
                        final translatedTypes = snapshot.data ?? _problemTypes;
                        return DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue.shade100.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: List.generate(_problemTypes.length, (i) {
                            return DropdownMenuItem(
                              value: _problemTypes[i],
                              child: Text(translatedTypes[i]),
                            );
                            }),
                            onChanged: (val) {
                            setState(() {
                              _selectedType = val;
                            });
                            },
                            validator: (val) => val == null
                              ? (snapshot.hasData
                                ? translatedTypes[0]
                                : 'Select a type')
                              : null,
                            isExpanded: true, // Makes dropdown take full width
                            icon: Icon(Icons.arrow_drop_down, color: primaryBlue),
                            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                            menuMaxHeight: 300, // Prevents dropdown from covering too much
                          );
                      },
                    ),
                    if (_selectedType == 'Other')
                      Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FutureBuilder<List<String>>(
                        future: Future.wait([
                        _translateText('Please specify the problem', currentLanguage),
                        _translateText('Please specify the problem', currentLanguage),
                        ]),
                        builder: (context, snapshot) {
                        final label = snapshot.data?[0] ?? 'Please specify the problem';
                        final validatorText = snapshot.data?[1] ?? 'Please specify the problem';
                        return TextFormField(
                          controller: _otherTypeController,
                          decoration: InputDecoration(
                          labelText: label,
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark
                            ? Colors.grey.shade900
                            : Colors.blue.shade50,
                          ),
                          style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          ),
                          validator: (val) {
                          if (_selectedType == 'Other' &&
                            (val == null || val.trim().isEmpty)) {
                            return validatorText;
                          }
                          return null;
                          },
                        );
                        },
                      ),
                      ),
                    SizedBox(height: 16),
                    FutureBuilder<List<String>>(
                      future: Future.wait([
                        _translateText('Describe the issue', currentLanguage),
                        _translateText('Enter description', currentLanguage),
                      ]),
                        builder: (context, snapshot) {
                        final label = snapshot.data?[0] ?? 'Describe the issue';
                        final validatorText = snapshot.data?[1] ?? 'Enter description';
                        return TextFormField(
                          controller: _descController,
                          maxLines: 4,
                          decoration: InputDecoration(
                          labelText: label,
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark
                            ? Colors.grey.shade900
                            : Colors.blue.shade50,
                          ),
                          style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          ),
                          validator: (val) =>
                            val == null || val.trim().isEmpty ? validatorText : null,
                        );
                        },
                      ),
                    SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: _translateText('Choose a Location', currentLanguage),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Choose a Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ),
                    FutureBuilder<List<String>>(
                      future: Future.wait([
                        _translateText('Pick Location on Map', currentLanguage),
                        _translateText('Location Selected', currentLanguage),
                      ]),
                      builder: (context, snapshot) {
                        final pickLocation = snapshot.data?[0] ?? 'Pick Location on Map';
                        final locationSelected = snapshot.data?[1] ?? 'Location Selected';
                        return ElevatedButton.icon(
                          icon: Icon(Icons.location_pin, color: Colors.white),
                          label: Text(
                            _latitude == null ? pickLocation : locationSelected,
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _selectLocationOnMap,
                        );
                      },
                    ),
                    if (_latitude != null && _longitude != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: FutureBuilder<List<String>>(
                          future: Future.wait([
                            _translateText('Lat', currentLanguage),
                            _translateText('Long', currentLanguage),
                          ]),
                          builder: (context, snapshot) {
                            final latLabel = snapshot.data?[0] ?? 'Lat';
                            final longLabel = snapshot.data?[1] ?? 'Long';
                            return Text(
                              '$latLabel: ${_latitude!.toStringAsFixed(5)}, $longLabel: ${_longitude!.toStringAsFixed(5)}',
                              style: TextStyle(color: Colors.blue.shade900),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: _translateText("Upload a Photo", currentLanguage),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? "Upload a Photo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryBlue, width: 1.2),
                        ),
                        child: _imageFile == null
                            ? Center(
                                child: Icon(Icons.add_a_photo, size: 40, color: primaryBlue),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  width: 300,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: _translateText('Submit', currentLanguage),
                      builder: (context, snapshot) {
                        return ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                          child: Text(snapshot.data ?? 'Submit',
                              style: TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
