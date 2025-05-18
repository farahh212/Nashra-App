

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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('NASHRA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),

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
// TextButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
//     );
//   },
//   child: Text('View results', style: TextStyle(color: Color(0xFF1B5E20))),
// )
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