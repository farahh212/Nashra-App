// Emergency Screen
// This file will contain emergency-related screens and UI components 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/emergency_number.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../providers/emergencyProvider.dart';
import '../providers/authProvider.dart' as my_auth;
import '../widgets/emergency_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/languageProvider.dart';

class EmergencyNumbersScreen extends StatefulWidget {
  const EmergencyNumbersScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyNumbersScreen> createState() => _EmergencyNumbersScreenState();
}

class _EmergencyNumbersScreenState extends State<EmergencyNumbersScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
        setState(() {
          _isAdmin = authProvider.isAdmin;
        });
      }
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: _isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          _isAdmin ? l10n.manageEmergencyNumbers : l10n.emergencyNumbers,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        l10n.emergencyNumbers,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.phone, color: AppTheme.primaryColor, size: 24),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer<EmergencyProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (provider.error != null) {
                          return Center(child: Text('Error: ${provider.error}'));
                        }

                        if (provider.emergencyNumbers.isEmpty) {
                          return Center(child: Text(l10n.noEmergencyNumbers));
                        }

                        return ListView.builder(
                          itemCount: provider.emergencyNumbers.length,
                          itemBuilder: (context, index) {
                            final contact = provider.emergencyNumbers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: EmergencyContactTile(
                                contact: contact,
                                onDelete: _isAdmin ? () async {
                                  try {
                                    await provider.deleteEmergencyNumber(contact.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.emergencyNumberDeleted)),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.errorDeletingContact(e.toString()))),
                                      );
                                    }
                                  }
                                } : null,
                                onEdit: _isAdmin ? () => _editContact(
                                  contact.id,
                                  contact.title,
                                  contact.number,
                                ) : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isAdmin)
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              child: FloatingActionButton(
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add, size: 30),
                onPressed: _showAddDialog,
              ),
            ),
          const CustomBottomNavigationBar(),
        ],
      ),
    );
  }

  Future<void> _showAddDialog() async {
    _titleController.clear();
    _numberController.clear();
    
    return showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final languageProvider = Provider.of<LanguageProvider>(context);
        final isArabic = languageProvider.currentLocale.languageCode == 'ar';
        
        return AlertDialog(
          title: Text(l10n.addEmergencyNumber),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'العنوان بالعربية' : l10n.title,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: l10n.emergencyNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _numberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pleaseFillAllFields)),
                  );
                  return;
                }

                try {
                  final number = int.tryParse(_numberController.text);
                  if (number == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseEnterValidNumber)),
                    );
                    return;
                  }

                  final provider = Provider.of<EmergencyProvider>(context, listen: false);
                  await provider.addEmergencyNumber(
                    isArabic ? '' : _titleController.text,
                    number,
                    titleAr: isArabic ? _titleController.text : '',
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.emergencyNumberAdded)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorAddingContact(e.toString()))),
                    );
                  }
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editContact(String id, String currentTitle, int currentNumber) async {
    _titleController.text = currentTitle;
    _numberController.text = currentNumber.toString();

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.editEmergencyNumber),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: l10n.emergencyNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _numberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pleaseFillAllFields)),
                  );
                  return;
                }

                try {
                  final number = int.tryParse(_numberController.text);
                  if (number == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseEnterValidNumber)),
                    );
                    return;
                  }

                  final provider = Provider.of<EmergencyProvider>(context, listen: false);
                  await provider.updateEmergencyNumber(id, _titleController.text, number);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.emergencyNumberUpdated)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorUpdatingContact(e.toString()))),
                    );
                  }
                }
              },
              child: Text(l10n.update),
            ),
          ],
        );
      },
    );
  }
}

class EmergencyContactTile extends StatelessWidget {
  final EmergencyNumber contact;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const EmergencyContactTile({
    Key? key,
    required this.contact,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                '${contact.title}  ${contact.number}',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppTheme.errorColor),
              onPressed: onDelete,
            ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: onEdit,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
} 