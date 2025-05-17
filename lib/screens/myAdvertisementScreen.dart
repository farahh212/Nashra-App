import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';

class MyAdvertisementsScreen extends StatefulWidget {
  @override
  _MyAdvertisementsScreenState createState() => _MyAdvertisementsScreenState();
}

class _MyAdvertisementsScreenState extends State<MyAdvertisementsScreen> {
  List<Advertisement> _userAds = [];
  bool _isLoading = true;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final adProvider = Provider.of<AdvertisementProvider>(context, listen: false);

    adProvider.getUserAdvertisements(token, userId).then((ads) {
      setState(() {
        _userAds = ads; // includes all ads regardless of status
        _isLoading = false;
      });
    });
  }

  void _confirmAndDeleteAdFor(Advertisement ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to delete the advertisement for '${ad.title}'?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final token = Provider.of<AuthProvider>(context, listen: false).token;
                    final adProvider = Provider.of<AdvertisementProvider>(context, listen: false);
                    await adProvider.deleteAdvertisemnt(ad.id, token);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Advertisement deleted successfully')),
                    );
                    setState(() {
                      _userAds.removeWhere((a) => a.id == ad.id);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('No'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _showUpdateFormFor(Advertisement ad) {
    final _formKey = GlobalKey<FormState>();
    String updatedTitle = ad.title;
    String updatedDescription = ad.description;
    String updatedImageUrl = ad.imageUrl ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color(0xFFF7F6E7),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Update Advertisement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade900)),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: updatedTitle,
                      decoration: InputDecoration(labelText: "New Title :", border: OutlineInputBorder()),
                      onChanged: (val) => updatedTitle = val,
                      validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: updatedDescription,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: "New Description :", border: OutlineInputBorder()),
                      onChanged: (val) => updatedDescription = val,
                      validator: (val) => val == null || val.isEmpty ? 'Description required' : null,
                    ),
                    SizedBox(height: 16),
                    Text("Select New Image:"),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final token = Provider.of<AuthProvider>(context, listen: false).token;
                          final adProvider = Provider.of<AdvertisementProvider>(context, listen: false);
                          final updatedAd = Advertisement(
                            id: ad.id,
                            title: updatedTitle,
                            description: updatedDescription,
                            imageUrl: _pickedImage?.path ?? ad.imageUrl,
                            status: ad.status, // keep current status
                            ownerId: ad.ownerId,
                          );
                          await adProvider.updateAdvertisement(ad.id, updatedAd, token);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Advertisement updated")),
                          );
                          setState(() {
                            int index = _userAds.indexWhere((a) => a.id == ad.id);
                            _userAds[index] = updatedAd;
                            _pickedImage = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Advertisements")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userAds.isEmpty
              ? Center(child: Text("You have no ads."))
              : ListView.builder(
                  itemCount: _userAds.length,
                  itemBuilder: (ctx, i) {
                    final ad = _userAds[i];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ad.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 8),
                            Text(ad.description),
                            if (ad.imageUrl != null && ad.imageUrl!.startsWith('http'))
                              Image.network(ad.imageUrl!)
                            else if (ad.imageUrl != null && ad.imageUrl!.startsWith('/data/'))
                              Image.file(File(ad.imageUrl!)),
                            SizedBox(height: 8),
                            Text("Status: ${ad.status.name}", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.grey[700])),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showUpdateFormFor(ad),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text('Update'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _confirmAndDeleteAdFor(ad),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
