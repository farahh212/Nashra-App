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
        title: Text(id == null ? 'Add Emergency Number' : 'Edit Emergency Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
    return Scaffold(
      drawer: _isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isAdmin ? 'Manage Emergency Numbers' : 'Emergency Numbers',
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final items = provider.emergencyNumbers;
          if (items.isEmpty) {
            return const Center(child: Text('No emergency numbers found'));
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.phone, color:  Color(0xFF1B5E20)),
                    title: Text('${contact.title} - ${contact.number}'),
                    trailing: _isAdmin
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showAddOrEditDialog(
                                  id: contact.id,
                                  currentTitle: contact.title,
                                  currentNumber: contact.number,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
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
              backgroundColor: Color.fromARGB(255, 248, 249, 248),
              onPressed: () => _showAddOrEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
