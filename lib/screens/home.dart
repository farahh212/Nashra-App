

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../Sidebars/CitizenSidebar.dart';
// import '../Sidebars/govSidebar.dart';
// import '../utils/theme.dart';
// import '../providers/authProvider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../widgets/bottom_navigation_bar.dart';
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//     String? userEmail;

//     @override
//   void initState() {
//     super.initState();
//     _loadEmail();
//   }

//   void _loadEmail() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final email = await getNameByUid(authProvider.userId);
//     setState(() {
//       userEmail = email;
//     });
//     print('User email: $userEmail');
//   }

//    Future<String> getNameByUid(String uid) async {
//     final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     if (doc.exists && doc.data()?['name'] != null) {
//       return doc.data()?['name'];
//     }
//     return 'government'; // default fallback
//   }

  

 

  
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isAdmin = authProvider.isAdmin;
//     final theme = Theme.of(context);
    

 

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       drawer: isAdmin ? const GovSidebar() : const CitizenSidebar(),
//       appBar: AppBar(
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         elevation: 0,
//         title: Text(
//           'Welcome to Nashra',
//           style: theme.appBarTheme.titleTextStyle,
//         ),
//         iconTheme: theme.appBarTheme.iconTheme,
//         actions: [
//           IconButton(
//             icon: Icon(
//               themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//               color: theme.appBarTheme.iconTheme?.color,
//             ),
//             onPressed: () => themeProvider.toggleTheme(),
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           // Header
//           Container(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: theme.colorScheme.onPrimary,
//                   child: Icon(Icons.person, color: theme.colorScheme.primary),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                  userEmail != null ? 'Hi, $userEmail' : 'Hi, User',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
  
// ),
//                 const SizedBox(height: 4),
//                 Text(
//                   isAdmin
//                       ? 'Welcome to Nashra Government Services'
//                       : 'Welcome to Nashra E-Office Services',
//                   style: TextStyle(
//                     color: theme.colorScheme.onPrimary.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Feature Cards
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: theme.cardTheme.color,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Wrap(
//                 alignment: WrapAlignment.center,
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: isAdmin ? _adminFeatures(context) : _citizenFeatures(context),
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Highlights
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'Highlights',
//               style: theme.textTheme.titleLarge,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ..._buildHighlights(context, isAdmin),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(),
//     );
//   }

//   List<Widget> _adminFeatures(BuildContext context) => [
//         _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
//         _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
//         _buildFeatureTile(context, Icons.campaign, 'Ads', '/gov_advertisement'),
//         _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
//         _buildFeatureTile(context, Icons.report, 'Reports', '/gov_reports'),
//         _buildFeatureTile(context, Icons.analytics, 'Analytics', '/analytics'),
//         _buildFeatureTile(context, Icons.chat, 'Messages', '/gov_chats'),
//       ];

//   List<Widget> _citizenFeatures(BuildContext context) => [
//         _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
//         _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
//         _buildFeatureTile(context, Icons.campaign, 'Ads', '/advertisement'),
//         _buildFeatureTile(context, Icons.chat, 'Contact', '/chats'),
//         _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
//         _buildFeatureTile(context, Icons.report, 'Report', '/reports'),
//       ];

//   List<Widget> _buildHighlights(BuildContext context, bool isAdmin) => isAdmin
//       ? [
//           _buildHighlightCard(title: "System Alert", subtitle: "Check latest emergency updates."),
//           _buildHighlightCard(title: "New Report Filed", subtitle: "View the latest citizen reports."),
//         ]
//       : [
//           _buildHighlightCard(title: 'New Announcement', subtitle: 'Check out the latest updates from the city council.', onTap: () => Navigator.pushNamed(context, '/announcements')),
//           _buildHighlightCard(title: 'Ongoing Poll', subtitle: 'Your feedback matters! Cast your vote now.', onTap: () => Navigator.pushNamed(context, '/polls')),
//           _buildHighlightCard(title: 'Featured Ad', subtitle: "Don't miss our latest government announcements.", onTap: () => Navigator.pushNamed(context, '/advertisement')),
//           _buildHighlightCard(title: 'Emergency Info', subtitle: 'Access contacts and services for urgent help.', onTap: () => Navigator.pushNamed(context, '/emergency')),
//         ];

//   Widget _buildFeatureTile(BuildContext context, IconData icon, String label, String route) {
//     final theme = Theme.of(context);
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, route),
//       child: SizedBox(
//         width: 80,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//               child: Icon(icon, size: 25, color: theme.colorScheme.primary),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: theme.textTheme.bodyMedium?.color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHighlightCard({required String title, required String subtitle, VoidCallback? onTap}) {
//     return Builder(
//       builder: (context) {
//         final theme = Theme.of(context);
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
//           child: GestureDetector(
//             onTap: onTap,
//             child: Card(
//               color: theme.cardTheme.color,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(14.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         color: theme.textTheme.bodyMedium?.color,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userEmail;
  bool isLoading = true;
  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _dataLoadingFuture = _fetchData();
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
      drawer: isAdmin ?  GovSidebar() : const CitizenSidebar(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'Welcome to Nashra',
          // style: theme.appBarTheme.titleTextStyle,
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
                'Error loading data',
                style: TextStyle(
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                ),
              ),
            );
          } else {
            return ListView(
              children: [
                // Header
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
                        userEmail != null ? 'Hi, $userEmail' : 'Hi, User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAdmin
                            ? 'Welcome to Nashra Government Services'
                            : 'Welcome to Nashra E-Office Services',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Feature Cards
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

                // Announcements Carousel
                if (announcementsProvider.announcements.isNotEmpty)
                  _buildAnnouncementsCarousel(context, announcementsProvider.announcements,pollsProvider.polls),
                
              ],
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildAnnouncementsCarousel(BuildContext context, List<Announcement> announcements, List<Poll> polls) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Combine and limit to 3 items (you can adjust this logic as needed)
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
              'Highlights',
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
                'View All',
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
            // Left image (or fallback)
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

            // Right content
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
                      'Tap to view details',
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
                        'Poll: ${poll.question}',
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
                        'Tap to vote',
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


 



  List<Widget> _adminFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
        _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
        _buildFeatureTile(context, Icons.campaign, 'Ads', '/gov_advertisement'),
        _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
        _buildFeatureTile(context, Icons.report, 'Reports', '/govreports'),
        _buildFeatureTile(context, Icons.analytics, 'Analytics', '/analytics'),
        _buildFeatureTile(context, Icons.chat, 'Messages', '/gov_chats'),
      ];

  List<Widget> _citizenFeatures(BuildContext context) => [
        _buildFeatureTile(context, Icons.announcement, 'Announcements', '/announcements'),
        _buildFeatureTile(context, Icons.poll, 'Polls', '/polls'),
        _buildFeatureTile(context, Icons.campaign, 'Ads', '/advertisement'),
        _buildFeatureTile(context, Icons.chat, 'Contact', '/chats'),
        _buildFeatureTile(context, Icons.phone, 'Emergency', '/emergency'),
        _buildFeatureTile(context, Icons.report, 'Report', '/reports'),
      ];

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
