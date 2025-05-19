import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/emergency_number.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../providers/emergencyProvider.dart';
import '../providers/authProvider.dart' as my_auth;
import '../utils/theme.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      final token = authProvider.token;
      Provider.of<EmergencyProvider>(context, listen: false).fetchEmergencyNumbers(token);
    });
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

  Future<void> _showAddOrEditDialog({
    String? id,
    String? currentTitle,
    int? currentNumber,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: Text(
          id == null ? 'Add Emergency Number' : 'Edit Emergency Number',
          style: TextStyle(
            color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
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
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: 'Number',
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final number = int.tryParse(_numberController.text.trim());

              if (title.isEmpty || number == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid title and number')),
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
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            ),
            child: Text(id == null ? 'Add' : 'Update'),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          _isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers',
          style: TextStyle(
            color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: TextStyle(
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            );
          }

          final items = provider.emergencyNumbers;
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No emergency numbers found',
                style: TextStyle(
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
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
                  child: ListTile(
                    leading: Icon(
                      Icons.phone,
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                    title: Text(
                      '${contact.title} - ${contact.number}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
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
                                      const SnackBar(content: Text('Deleted successfully')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              )
                            ],
                          )
                        : null,
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
    );
  }
}
