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

class MyAdvertisementsScreen extends StatefulWidget {
  @override
  _MyAdvertisementsScreenState createState() => _MyAdvertisementsScreenState();
}

class _MyAdvertisementsScreenState extends State<MyAdvertisementsScreen> {
  List<Advertisement> _userAds = [];
  bool _isLoading = true;
  bool _hasError = false;
  File? _pickedImage;
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};

  Future<String> _translateText(String text, String targetLang) async {
    final key = '${text}_$targetLang';
    if (_translations.containsKey(key)) {
      return _translations[key]!;
    }
    try {
      final translation = await _translator.translate(text, to: targetLang);
      _translations[key] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  Future<void> _loadUserAds() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final ads = await Provider.of<AdvertisementProvider>(context, listen: false)
          .getUserAdvertisements(token, userId);
          
      setState(() {
        _userAds = ads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserAds();
  }

  void _confirmAndDeleteAdFor(Advertisement ad) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;

    final title = await _translateText("Delete Advertisement", currentLanguage);
    final content = await _translateText(
      "Are you sure you want to delete the advertisement for '${ad.title}'?",
      currentLanguage,
    );
    final yesText = await _translateText("Yes", currentLanguage);
    final noText = await _translateText("No", currentLanguage);
    final successMessage = await _translateText(
      "Advertisement deleted successfully",
      currentLanguage,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(title, textAlign: TextAlign.center),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final token = Provider.of<AuthProvider>(context, listen: false).token;
              final adProvider = Provider.of<AdvertisementProvider>(context, listen: false);
              await adProvider.deleteAdvertisemnt(ad.id, token);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(successMessage)),
              );
              await _loadUserAds(); // Refresh the list after deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: Text(yesText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text(noText),
          ),
        ],
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

  void _showUpdateFormFor(Advertisement ad) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.currentLanguageCode;

    final formTitle = await _translateText("Update Advertisement", currentLanguage);
    final titleLabel = await _translateText("New Title", currentLanguage);
    final descLabel = await _translateText("New Description", currentLanguage);
    final imageLabel = await _translateText("Select New Image", currentLanguage);
    final submitText = await _translateText("Submit", currentLanguage);
    final titleRequired = await _translateText("Title required", currentLanguage);
    final descRequired = await _translateText("Description required", currentLanguage);
    final successMessage = await _translateText("Advertisement updated", currentLanguage);

    final _formKey = GlobalKey<FormState>();
    String updatedTitle = ad.title;
    String updatedDescription = ad.description;
    File? pickedImageTemp = _pickedImage;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: updatedTitle,
                      decoration: InputDecoration(
                        labelText: "$titleLabel:",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => updatedTitle = val,
                      validator: (val) => val == null || val.isEmpty ? titleRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: updatedDescription,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "$descLabel:",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => updatedDescription = val,
                      validator: (val) => val == null || val.isEmpty ? descRequired : null,
                    ),
                    const SizedBox(height: 16),
                    Text(imageLabel),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setStateDialog(() {
                            pickedImageTemp = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: pickedImageTemp != null
                            ? Image.file(pickedImageTemp!, fit: BoxFit.cover)
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
                            imageUrl: pickedImageTemp?.path ?? ad.imageUrl,
                            status: ad.status,
                            ownerId: ad.ownerId,
                          );
                          await adProvider.updateAdvertisement(ad.id, updatedAd, token);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(successMessage)),
                          );
                          await _loadUserAds(); // Refresh the list after update
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                      child: Text(submitText),
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

  Widget _buildEmptyState(BuildContext context, String currentLanguage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.announcement_outlined,
            size: 64,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: _translateText("You don't have any ads yet", currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "You don't have any ads yet",
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _translateText("Create your first advertisement now", currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Create your first advertisement now",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String currentLanguage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: _translateText("Failed to load your ads", currentLanguage),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Failed to load your ads",
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserAds,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            child: FutureBuilder<String>(
              future: _translateText("Try Again", currentLanguage),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? "Try Again");
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _translateText("My Advertisements", currentLanguage),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? "My Advertisements");
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserAds,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? _buildErrorState(context, currentLanguage)
                : _userAds.isEmpty
                    ? _buildEmptyState(context, currentLanguage)
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
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 40),
                          );

                          if (hasImage) {
                            if (isLocal) {
                              imageWidget = Image.file(
                                File(ad.imageUrl!), 
                                width: 100, 
                                height: 100, 
                                fit: BoxFit.cover
                              );
                            } else if (isNetwork) {
                              imageWidget = Image.network(
                                ad.imageUrl!, 
                                width: 100, 
                                height: 100, 
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 40),
                                ),
                              );
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageWidget,
                              ),
                              title: Text(ad.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ad.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Status: ${ad.status.name}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showUpdateFormFor(ad),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmAndDeleteAdFor(ad),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}