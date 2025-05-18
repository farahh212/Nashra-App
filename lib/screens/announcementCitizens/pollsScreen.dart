

import 'package:flutter/material.dart';
import 'package:nashra_project2/Sidebars/citizenSidebar.dart';
import 'package:nashra_project2/Sidebars/govSidebar.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/authProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:nashra_project2/screens/analytics_screen.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/ButtomSheetAnnouncement.dart';
import 'package:nashra_project2/screens/announcement&pollGovernment/ButtomSheetPolls.dart';
import './pollsCard.dart';
import 'package:provider/provider.dart';

class pollScreen extends StatefulWidget{

  const pollScreen({super.key});

  @override
  State<pollScreen> createState() => _pollScreenState();
}

class _pollScreenState extends State<pollScreen> {

   late Future<void> pollsFuture;
   String selectedButton = 'Polls';

   @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pollsProvider = Provider.of<Pollsprovider>(context, listen: false);
    pollsFuture = pollsProvider.fetchPollsFromServer(auth.token);
    
  }
  @override
  Widget build(BuildContext context) {
    
    final pollsProvider = Provider.of<Pollsprovider>(context);
    final polls = pollsProvider.polls; 
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isAdmin;


    return Scaffold(
      backgroundColor: Color(0xFFFEFFF3),
      appBar: AppBar(
        title: Text('NASHRA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFEFFF3),

                actions: [
          if(isAdmin)
IconButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take full height
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.50,
        child: Buttomsheetpolls(), // Make sure this class/widget exists and is correctly named
      ),
    );
  },
  icon: Icon(Icons.add, color: Colors.black),
  
),
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  },
  child: Text('View results'),
)
        ],

        
      ),
      drawer: isAdmin? GovSidebar():CitizenSidebar(), 
      body: FutureBuilder(
        future: pollsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading announcements'));
          } else {
            return Column(
              children: [
                SizedBox(height: 20),
                Container(
                   child:  Row(children: [
  SizedBox(width: 60),
                    TextButton(onPressed: () {
                      setState(() {
                         Navigator.pushNamed(context, '/announcements');
                selectedButton = 'Announcements';
              });
                    },style: TextButton.styleFrom(
    backgroundColor: selectedButton == 'Announcements' ? Colors.green :const Color.fromARGB(255, 106, 106, 106),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Optional padding
  ), child: Text('Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 247, 253, 248)))),
  SizedBox(width: 16),
TextButton(onPressed: () {
                      setState(() {
                        Navigator.pushNamed(context, '/polls');
                selectedButton = 'Polls';
              });
},style: TextButton.styleFrom(
    backgroundColor: selectedButton == 'Polls' ? Colors.green : const Color.fromARGB(255, 106, 106, 106), // Set background color here
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Optional padding
  ), child: Text('Polls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 247, 253, 248)))),

                   ],)
                ),
                SizedBox(height: 30),
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
    );
  }
}

// 