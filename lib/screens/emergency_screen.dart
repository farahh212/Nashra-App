// Emergency Screen
// This file will contain emergency-related screens and UI components 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_number.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../providers/emergencyProvider.dart';
import '../providers/authProvider.dart' as my_auth;
import '../widgets/emergency_widget.dart';

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

  Future<void> _showAddDialog() async {
    _titleController.clear();
    _numberController.clear();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (e.g., Police, Ambulance)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Emergency Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty || _numberController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              try {
                final number = int.tryParse(_numberController.text);
                if (number == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number')),
                  );
                  return;
                }

                final provider = Provider.of<EmergencyProvider>(context, listen: false);
                await provider.addEmergencyNumber(_titleController.text, number);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emergency number added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding contact: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editContact(String id, String currentTitle, int currentNumber) async {
    _titleController.text = currentTitle;
    _numberController.text = currentNumber.toString();

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Emergency Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (e.g., Police, Ambulance)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Emergency Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty || _numberController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              try {
                final number = int.tryParse(_numberController.text);
                if (number == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number')),
                  );
                  return;
                }

                final provider = Provider.of<EmergencyProvider>(context, listen: false);
                await provider.updateEmergencyNumber(id, _titleController.text, number);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emergency number updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating contact: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          _isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
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
                        'Emergency Numbers',
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
                          return const Center(child: Text('No emergency numbers found'));
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
                                        const SnackBar(content: Text('Emergency number deleted successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error deleting contact: $e')),
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
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(
                top: BorderSide(color: AppTheme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home, color: AppTheme.primaryColor, size: 28),
                Icon(Icons.notifications_outlined, color: AppTheme.primaryColor, size: 28),
                Icon(Icons.language, color: AppTheme.primaryColor, size: 28),
                Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
              ],
            ),
          ),
        ],
      ),
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