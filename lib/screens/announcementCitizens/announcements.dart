import 'package:flutter/material.dart';
import 'package:nashra_project2/Sidebars/govSidebar.dart';
// import 'package:nashra_project2/CitizenPages/announcementCard.dart' ;
import './announcements.dart';
import 'package:nashra_project2/models/announcement.dart';
import './announcementsCard.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/ButtomSheetAnnouncement.dart';
import 'package:nashra_project2/widgets/bottom_navigation_bar.dart';
import 'package:nashra_project2/Sidebars/citizenSidebar.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:provider/provider.dart';
// import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart' ;// Replace with the correct path
import 'package:nashra_project2/providers/languageProvider.dart';
import 'package:nashra_project2/screens/announcementCitizens/pollsScreen.dart';
import 'package:translator/translator.dart';

class Announcements extends StatefulWidget {
  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  late Future<void> _announcementsFuture;
  String selectedButton = 'Announcements';
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

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final announcementsProvider = Provider.of<Announcementsprovider>(context, listen: false);
    _announcementsFuture = announcementsProvider.fetchAnnouncementsFromServer(auth.token);
  }

  @override
  Widget build(BuildContext context) {
    final announcementsProvider = Provider.of<Announcementsprovider>(context);
    final announcements = announcementsProvider.announcements;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            );
          },
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
        ),
        elevation: 0,
        actions: [
          if(isAdmin)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: Buttomsheetannouncement(),
                  ),
                );
              },
              icon: Icon(
                Icons.add,
                color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
              ),
            )
        ],
      ),
      drawer:isAdmin? GovSidebar():CitizenSidebar(), 
      body: FutureBuilder(
        future: _announcementsFuture,
        builder: (ctx, snapshot) {
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
              child: FutureBuilder<String>(
                future: _translateText('Error loading announcements', currentLang),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Error loading announcements',
                    style: TextStyle(
                      color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    ),
                  );
                },
              ),
            );
          } else {
            return Column(
              children: [
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pushNamed(context, '/announcements');
                            selectedButton = 'Announcements';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: selectedButton == 'Announcements'
                              ? (isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2))
                              : Colors.grey[700],
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: FutureBuilder<String>(
                          future: _translateText('Announcements', currentLang),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Announcements',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pushNamed(context, '/polls');
                            selectedButton = 'Polls';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: selectedButton == 'Polls'
                              ? (isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2))
                              : Colors.grey[700],
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: FutureBuilder<String>(
                          future: _translateText('Polls', currentLang),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Polls',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (ctx, i) => Announcementcard(announcement: announcements[i]),
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


//NOTE: (since I created the authprovider, u will find methods to extract and use token details)
// from chatgpt:
// Once you've implemented a get token and get userId in your AuthProvider,
// you can access these values globally without needing to pass them explicitly to other classes or widgets. 
//This means you can avoid passing the token and user ID to each constructor and simplify your code significantly.
//ex: final token = Provider.of<AuthProvider>(context).token;
//ex: final userId = Provider.of<AuthProvider>(context).userId;
// This way, you can use the token and user ID wherever you need them in your app without cluttering your widget constructors with these parameters.
//if you get an error in authprovider being double imported rename it in the import using 'as my_auth' or something similar

//in urls later on, use the token and userId from the authprovider to get the data from the server
//format to add at the end of the url:  ?auth=[our token value] 
//ex: var ideasURL =Uri.parse('https://our DB URL/IdeasDB.json?auth=$token’);

//IMPP: STILL can include userId in constructor if needed, but not the token, since we can access it globally now
//this can be the case if we want to use the userId to get specific data from the server, like in the case of the ideas page, where we want to get the ideas of a specific user


//in firebase endpoints, the urls are usually in the format of: https://[your-project-id].firebaseio.com/[your-database-name].json?auth=[your-token] for POST and GET ALL
//for get one, include id, for example: https://[your-project-id].firebaseio.com/[your-database-name]/[id].json?auth=[your-token]
//our project id is nahra-316ee

//also all records in the database are stored in the format of: { "userId": "userId", "data": "data" } as key-value pairs
//with a key for all of this which is the id of the record, which is a random string generated by firebase


//ex: 
// "IdeasDB": { //database name
//   "-NnHtHf1djsAaaJkl9": { //automatically generated key by firebase
//     "title": "My Idea",
//     "description": "This is my idea"
//   },
//   "-NnHuJa92aaAkd993": {
//     "title": "Another Idea",
//     "description": "Second one"
//   }
// }

//read token, userId, and do preprocessing steps in the initState method


// connecting your other providers to the AuthProvider using ChangeNotifierProxyProvider
// in main.dart is a best practice if those providers depend on authentication info, 
// like the token or userId
// When AuthProvider updates (notifyListeners() after login/logout),
// IdeasProvider's update function is re-run with the new token/userId.
// This keeps all your dependent providers in sync with auth.


//final note: add logout button in the app bar of the pages, it will call the logout method in the authprovider and redirect to the login page
//ex:
// IconButton(onPressed: () {
//                            authProvider.logout();
//                            Navigator.of(context).pushReplacementNamed('/'); }, 
//            icon: Icon(Icons.logout_rounded))
// ],


//note: getting idea by its id is simple but getting all ideas by userId required filtering by orderBy and equalTo in the url
//to get all ideas for userId "abc123", the url would be: 'https://nahra-316ee.firebaseio.com/IdeasDB.json?auth=$token&orderBy="userId"&equalTo="abc123"' single-double quotes are important here
//must add an index in the firebase for every attribute we might use orderBy on.
//in firebase console, go to the database, then to the rules tab, and add the following code:
// {
//   "rules": {
//     ".read": "auth!=null",
//     ".write": "auth!=null",  
//     "IdeasDB": {
//       ".indexOn": ["userId"]
//     }
//   }
// }


//for later: if the token is still valid, user should not be prompted to login again
// Two ways to do this:
// In your Material app, set up the auth provider listener and depending on the isauthenticated value, we either show login page or ideas page.
// Always go to login page but in its initState, check for the authenticated variable, if true, navigate automatically to ideas page.
// i will implement the second one later on, since the first one is more complicated and i want to keep it simple for now