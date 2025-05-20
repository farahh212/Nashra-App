// map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import '../../providers/languageProvider.dart';

class MapScreen extends StatefulWidget {
    final LatLng initialPosition;
    final double initialZoom;

    const MapScreen({
        required this.initialPosition,
        this.initialZoom = 15, // Default zoom value
    });

    @override
    _MapScreenState createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  LatLng? _selectedLocation;




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


    void _onMapTap(LatLng position) {
        setState(() {
            _selectedLocation = position;
        });
    }



   Future<String> _getTranslatedProblemType(String type, String lang) async {
    return await _translateText(type, lang);
  }

    @override
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                String lang = languageProvider.currentLanguageCode;
                return FutureBuilder<String>(
                future: _translateText('Select Location', lang),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? 'Select Location');
                },
                );
              },
              ),
            ),
            body: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: widget.initialPosition,
                    zoom: widget.initialZoom,
                ),
                onTap: _onMapTap,
                markers: _selectedLocation == null
                        ? {}
                        : {
                                Marker(
                                    markerId: MarkerId('selected-location'),
                                    position: _selectedLocation!,
                                )
                            },
            ),
            floatingActionButton: _selectedLocation == null
                    ? null
                    : Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                                child: FloatingActionButton.extended(
                                    onPressed: () {
                                        Navigator.of(context).pop(_selectedLocation);
                                    },
                                    icon: Icon(Icons.check),
                                    label: Text('Confirm'),
                                ),
                            ),
                        ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
    }
}
