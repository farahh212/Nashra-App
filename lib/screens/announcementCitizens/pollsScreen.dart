import 'package:flutter/material.dart';
import 'package:nashra_project2/Sidebars/citizenSidebar.dart';
import 'package:nashra_project2/Sidebars/govSidebar.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:nashra_project2/screens/analytics_screen.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/ButtomSheetAnnouncement.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/ButtomSheetPolls.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import './pollsCard.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:nashra_project2/providers/languageProvider.dart';

class pollScreen extends StatefulWidget {
  const pollScreen({super.key});

  @override
  State<pollScreen> createState() => _pollScreenState();
}

class _pollScreenState extends State<pollScreen> {
  late Future<void> pollsFuture;
  String selectedButton = 'Polls';
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};
  String _addPollTooltip = 'Add New Poll';

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

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pollsProvider = Provider.of<Pollsprovider>(context, listen: false);
    pollsFuture = pollsProvider.fetchPollsFromServer(auth.token);
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;
    
    _addPollTooltip = await _translateText('Add New Poll', currentLang);
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pollsProvider = Provider.of<Pollsprovider>(context);
    final polls = pollsProvider.polls;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLanguageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _translateText('NASHRA', currentLang),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'NASHRA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            );
          },
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: isDark ? 0 : 1,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          if (isAdmin)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: Buttomsheetpolls(),
                  ),
                );
              },
              icon: Icon(Icons.add, color: primaryColor),
              tooltip: _addPollTooltip,
            ),
        ],
      ),
      drawer: isAdmin ? GovSidebar() : CitizenSidebar(),
      body: FutureBuilder(
        future: pollsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: isDark ? Colors.red[300] : Colors.red,
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _translateText('Error loading polls', currentLang),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Error loading polls',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Column(
              children: [
                SizedBox(height: 30),
                if (polls.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.poll_outlined,
                            size: 48,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          FutureBuilder<String>(
                            future: _translateText('No polls available', currentLang),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'No polls available',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: polls.length,
                      itemBuilder: (ctx, i) => PollCard(poll: polls[i]),
                    ),
                  ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
// TextButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
//     );
//   },
//   child: Text('View results', style: TextStyle(color: Color(0xFF1B5E20))),
// )