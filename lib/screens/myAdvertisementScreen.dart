import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nashra_project2/models/advertisement.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
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
        _userAds = ads;
        _isLoading = false;
      });
    });
  }

  void _confirmAndDeleteAdFor(Advertisement ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to delete the advertisement for '${ad.title}'?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 36),
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
                      const SnackBar(content: Text('Advertisement deleted successfully')),
                    );
                    setState(() {
                      _userAds.removeWhere((a) => a.id == ad.id);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                  child: const Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('No'),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Update Advertisement", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: updatedTitle,
                      decoration: const InputDecoration(
                          labelText: "New Title :", border: OutlineInputBorder()),
                      onChanged: (val) => updatedTitle = val,
                      validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: updatedDescription,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: "New Description :", border: OutlineInputBorder()),
                      onChanged: (val) => updatedDescription = val,
                      validator: (val) => val == null || val.isEmpty ? 'Description required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text("Select New Image:"),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : const Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            status: ad.status,
                            ownerId: ad.ownerId,
                          );
                          await adProvider.updateAdvertisement(ad.id, updatedAd, token);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Advertisement updated")),
                          );
                          setState(() {
                            int index = _userAds.indexWhere((a) => a.id == ad.id);
                            _userAds[index] = updatedAd;
                            _pickedImage = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                      child: const Text("Submit"),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Advertisements",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Color(0xFF1976D2),
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Color(0xFF1976D2),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userAds.isEmpty
              ? const Center(child: Text("You have no ads."))
              : ListView.builder(
                  itemCount: _userAds.length,
                  itemBuilder: (ctx, i) {
                    final ad = _userAds[i];
                    final hasImage = ad.imageUrl != null && ad.imageUrl!.isNotEmpty;
                    final isLocal = hasImage && ad.imageUrl!.startsWith('/data/');
                    final isNetwork = hasImage && ad.imageUrl!.startsWith('http');

                    Widget imageWidget = Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasImage
                            ? isNetwork
                                ? Image.network(
                                    ad.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  )
                                : Image.file(File(ad.imageUrl!), fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey),
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Theme.of(context).cardColor : Colors.white,
                          border: Border.all(
                              color: isDark ? Colors.grey[700]! : Colors.grey.shade300, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imageWidget,
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ad.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ad.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.white70 : Colors.black87),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Status: ${ad.status.name}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _showUpdateFormFor(ad),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1976D2),
                                          ),
                                          child: const Text('Update'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () => _confirmAndDeleteAdFor(ad),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
