import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:translator/translator.dart';

import '../Sidebars/CitizenSidebar.dart';
import '../Sidebars/govSidebar.dart';
import '../utils/theme.dart';
import '../providers/authProvider.dart';
import '../providers/announcementsProvider.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nashra_project2/models/announcement.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import '../models/poll.dart';
import '../../providers/languageProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userEmail;
  bool isLoading = true;
  late Future<void> _dataLoadingFuture;
  final _translator = GoogleTranslator();
  final Map<String, String> _translations = {};

  // Translation variables
  String _welcomeText = 'Welcome to Nashra';
  String _hiText = 'Hi, User';
  String _govServicesText = 'Welcome to Nashra Government Services';
  String _citizenServicesText = 'Welcome to Nashra E-Office Services';
  String _highlightsText = 'Highlights';
  String _viewAllText = 'View All';
  String _tapToViewText = 'Tap to view details';
  String _tapToVoteText = 'Tap to vote';
  String _errorLoadingText = 'Error loading data';
  String _pollText = 'Poll: ';

  // Feature labels
  String _emergencyText = 'Emergency';
  String _announcementsText = 'Announcements';
  String _adsText = 'Ads';
  String _pollsText = 'Polls';
  String _reportsText = 'Reports';
  String _analyticsText = 'Analytics';
  String _messagesText = 'Messages';
  String _contactText = 'Contact';
  String _reportText = 'Report';

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

  Future<void> _loadTranslations() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguageCode;
    
    _welcomeText = await _translateText('Welcome to Nashra', currentLang);
    _hiText = await _translateText('Hi, User', currentLang);
    _govServicesText = await _translateText('Welcome to Nashra Government Services', currentLang);
    _citizenServicesText = await _translateText('Welcome to Nashra E-Office Services', currentLang);
    _highlightsText = await _translateText('Highlights', currentLang);
    _viewAllText = await _translateText('View All', currentLang);
    _tapToViewText = await _translateText('Tap to view details', currentLang);
    _tapToVoteText = await _translateText('Tap to vote', currentLang);
    _errorLoadingText = await _translateText('Error loading data', currentLang);
    _pollText = await _translateText('Poll: ', currentLang);

    // Feature labels
    _emergencyText = await _translateText('Emergency', currentLang);
    _announcementsText = await _translateText('Announcements', currentLang);
    _adsText = await _translateText('Ads', currentLang);
    _pollsText = await _translateText('Polls', currentLang);
    _reportsText = await _translateText('Reports', currentLang);
    _analyticsText = await _translateText('Analytics', currentLang);
    _messagesText = await _translateText('Messages', currentLang);
    _contactText = await _translateText('Contact', currentLang);
    _reportText = await _translateText('Report', currentLang);
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _dataLoadingFuture = _fetchData();
    _loadTranslations();
  }

  void _loadEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = await getNameByUid(authProvider.userId);
    setState(() {
      userEmail = email;
    });
  }

  Future<String> getNameByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['name'] != null) {
      return doc.data()?['name'];
    }
    return 'government'; // default fallback
  }

  Future<void> _fetchData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
      
      await announcementsProvider.fetchAnnouncementsFromServer(authProvider.token);
      final pollsProvider = Provider.of<Pollsprovider>(context, listen: false);
      await pollsProvider.fetchPollsFromServer(authProvider.token);
      
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final announcementsProvider = Provider.of<Announcementsprovider>(context);
    final pollsProvider = Provider.of<Pollsprovider>(context);
    final isAdmin = authProvider.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: isAdmin ? GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          _welcomeText,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _dataLoadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                _errorLoadingText,
                style: TextStyle(
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            );
          } else {
            return ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.onPrimary,
                        child: Icon(Icons.person, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userEmail != null ? '$_hiText $userEmail' : _hiText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAdmin ? _govServicesText : _citizenServicesText,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: isAdmin ? _adminFeatures(context) : _citizenFeatures(context),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (announcementsProvider.announcements.isNotEmpty)
                  _buildAnnouncementsCarousel(context, announcementsProvider.announcements, pollsProvider.polls),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  List<Widget> _adminFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.phone, _emergencyText, '/emergency'),
        _buildFeatureTile(context, Icons.announcement, _announcementsText, '/announcements'),
        _buildFeatureTile(context, Icons.campaign, _adsText, '/gov_advertisement'),
        _buildFeatureTile(context, Icons.poll, _pollsText, '/polls'),
        _buildFeatureTile(context, Icons.report, _reportsText, '/govreports'),
        _buildFeatureTile(context, Icons.analytics, _analyticsText, '/analytics'),
        _buildFeatureTile(context, Icons.chat, _messagesText, '/gov_chats'),
      ];

  List<Widget> _citizenFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.announcement, _announcementsText, '/announcements'),
        _buildFeatureTile(context, Icons.poll, _pollsText, '/polls'),
        _buildFeatureTile(context, Icons.campaign, _adsText, '/advertisement'),
        _buildFeatureTile(context, Icons.chat, _contactText, '/chats'),
        _buildFeatureTile(context, Icons.phone, _emergencyText, '/emergency'),
        _buildFeatureTile(context, Icons.report, _reportText, '/reports'),
      ];

  Widget _buildAnnouncementsCarousel(BuildContext context, List<Announcement> announcements, List<Poll> polls) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final combinedItems = [
      ...announcements.take(3).map((a) => {'type': 'announcement', 'data': a}),
      ...polls.take(3).map((p) => {'type': 'poll', 'data': p}),
    ].toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.highlight, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                _highlightsText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/announcements'),
                child: Text(
                  _viewAllText,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CarouselSlider.builder(
          itemCount: combinedItems.length,
          options: CarouselOptions(
            height: 170,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          itemBuilder: (context, index, realIndex) {
            final item = combinedItems[index];
            
            if (item['type'] == 'announcement') {
              final announcement = item['data'] as Announcement;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/announcements', arguments: announcement.id),
                child: SizedBox(
                  height: 150,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    clipBehavior: Clip.hardEdge,
                    child: Row(
                      children: [
                        if (announcement.imageUrl != null && announcement.imageUrl!.isNotEmpty)
                          Image.network(
                            announcement.imageUrl!,
                            width: 100,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(
                              width: 100,
                              child: Icon(Icons.image_not_supported),
                            ),
                          )
                        else
                          Container(
                            width: 100,
                            color: theme.colorScheme.surfaceVariant,
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    announcement.description,
                                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tapToViewText,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              final poll = item['data'] as Poll;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/polls', arguments: poll.id),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_pollText${poll.question}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          poll.options.join(', '),
                          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          _tapToVoteText,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String label, String route) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(icon, size: 25, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
