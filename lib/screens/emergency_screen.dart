import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';

import '../models/emergency_number.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../providers/emergencyProvider.dart';
import '../providers/authProvider.dart' as my_auth;
import '../providers/languageProvider.dart';
import '../utils/theme.dart';
import '../widgets/bottom_navigation_bar.dart';

class EmergencyNumbersScreen extends StatefulWidget {
  const EmergencyNumbersScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyNumbersScreen> createState() => _EmergencyNumbersScreenState();
}

class _EmergencyNumbersScreenState extends State<EmergencyNumbersScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  bool _isAdmin = false;
  final _translator = GoogleTranslator();
  Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      final token = authProvider.token;
      Provider.of<EmergencyProvider>(context, listen: false).fetchEmergencyNumbers(token);
    });
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

  Future<void> _checkAdminStatus() async {
    try {
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      setState(() {
        _isAdmin = authProvider.isAdmin;
      });
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: FutureBuilder<String>(
          future: _translateText(
            _isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers',
            currentLanguage
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                _isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers',
                style: TextStyle(
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              );
            }
            return Text(
              snapshot.data ?? (_isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers'),
              style: TextStyle(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            );
          }
        ),
        iconTheme: IconThemeData(
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('Loading emergency numbers...', currentLanguage),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading emergency numbers...',
                        style: TextStyle(
                          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                        ),
                      );
                    }
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('Error: ${provider.error}', currentLanguage),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Error: ${provider.error}',
                        style: TextStyle(
                          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                        ),
                      );
                    }
                  ),
                ],
              ),
            );
          }

          final items = provider.emergencyNumbers;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_missed,
                    color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('No emergency numbers found', currentLanguage),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'No emergency numbers found',
                        style: TextStyle(
                          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                        ),
                      );
                    }
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final contact = items[i];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardTheme.color : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.phone,
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                    title: FutureBuilder<String>(
                      future: _translateText(contact.title, currentLanguage),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  contact.title,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Text(
                          snapshot.data ?? contact.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        );
                      }
                    ),
                    subtitle: Text(
                      contact.number.toString(),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: _isAdmin
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                                ),
                                onPressed: () => _showAddOrEditDialog(
                                  id: contact.id,
                                  currentTitle: contact.title,
                                  currentNumber: contact.number,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                                ),
                                onPressed: () async {
                                  final auth = Provider.of<my_auth.AuthProvider>(context, listen: false);
                                  final token = auth.token;
                                  try {
                                    await provider.deleteEmergencyNumber(token, contact.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: FutureBuilder<String>(
                                          future: _translateText('Deleted successfully', currentLanguage),
                                          builder: (context, snapshot) {
                                            return Text(snapshot.data ?? 'Deleted successfully');
                                          }
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: FutureBuilder<String>(
                                          future: _translateText('Error: $e', currentLanguage),
                                          builder: (context, snapshot) {
                                            return Text(snapshot.data ?? 'Error: $e');
                                          }
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          )
                        : null,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: FutureBuilder<String>(
                          future: _translateText(contact.title, currentLanguage),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? contact.title,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              onPressed: () => _showAddOrEditDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Future<void> _showAddOrEditDialog({
    String? id,
    String? currentTitle,
    int? currentNumber,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (id == null) {
      _titleController.clear();
      _numberController.clear();
    } else {
      _titleController.text = currentTitle ?? '';
      _numberController.text = currentNumber?.toString() ?? '';
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: FutureBuilder<String>(
          future: _translateText(
            id == null ? 'Add Emergency Number' : 'Edit Emergency Number',
            languageProvider.currentLanguageCode
          ),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? (id == null ? 'Add Emergency Number' : 'Edit Emergency Number'),
              style: TextStyle(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            );
          }
        ),
       content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    FutureBuilder<String>(
      future: _translateText('Title', languageProvider.currentLanguageCode),
      builder: (context, snapshot) {
        return TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: snapshot.data ?? 'Title',
            labelStyle: TextStyle(
              color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
          ),
        );
      },
    ),
    const SizedBox(height: 12),
    FutureBuilder<String>(
      future: _translateText('Number', languageProvider.currentLanguageCode),
      builder: (context, snapshot) {
        return TextField(
          controller: _numberController,
          decoration: InputDecoration(
            labelText: snapshot.data ?? 'Number',
            labelStyle: TextStyle(
              color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
          ),
          keyboardType: TextInputType.phone,
        );
      },
    ),
  ],
),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: FutureBuilder<String>(
              future: _translateText('Cancel', languageProvider.currentLanguageCode),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Cancel',
                  style: TextStyle(
                    color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                  ),
                );
              }
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final number = int.tryParse(_numberController.text.trim());

              if (title.isEmpty || number == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: FutureBuilder<String>(
                      future: _translateText(
                        'Please enter valid title and number',
                        languageProvider.currentLanguageCode
                      ),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? 'Please enter valid title and number');
                      }
                    ),
                  ),
                );
                return;
              }

              final auth = Provider.of<my_auth.AuthProvider>(context, listen: false);
              final provider = Provider.of<EmergencyProvider>(context, listen: false);
              final token = auth.token;

              try {
                if (id == null) {
                  await provider.addEmergencyNumber(token, title, number);
                } else {
                  await provider.updateEmergencyNumber(token, id, title, number);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            child: FutureBuilder<String>(
              future: _translateText(
                id == null ? 'Add' : 'Update',
                languageProvider.currentLanguageCode
              ),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? (id == null ? 'Add' : 'Update'));
              }
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    super.dispose();
  }
}
