import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/poll_results_widget.dart';
import '../models/poll.dart';
import '../services/poll_service.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart' as my_auth;

class PollResultsScreen extends StatefulWidget {
  final String pollId;

  const PollResultsScreen({
    Key? key,
    required this.pollId,
  }) : super(key: key);

  @override
  State<PollResultsScreen> createState() => _PollResultsScreenState();
}

class _PollResultsScreenState extends State<PollResultsScreen> {
  final PollService _pollService = PollService();
  bool _isLoading = true;
  Poll? _poll;
  String? _error;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadPoll();
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

  Future<void> _loadPoll() async {
    try {
      final poll = await _pollService.getPollById(widget.pollId);
      if (mounted) {
        setState(() {
          _poll = poll;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isAdmin ? const GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/nashra_logo.png',
          height: 40,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading poll results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPoll,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_poll == null) {
      return const Center(
        child: Text('Poll not found'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Poll Results',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3B2A),
              ),
            ),
          ),
          const SizedBox(height: 30),
          PollResultsWidget(poll: _poll!),
        ],
      ),
    );
  }
} 