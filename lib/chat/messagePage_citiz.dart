// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'message_page.dart';



// class CitizenMessageWrapper extends StatefulWidget {
//   const CitizenMessageWrapper({Key? key}) : super(key: key);

//   @override
//   State<CitizenMessageWrapper> createState() => _CitizenMessageWrapperState();
// }

// class _CitizenMessageWrapperState extends State<CitizenMessageWrapper> {
//   final String governmentEmail = 'government@nashra.com';

//   @override
//   void initState() {
//     super.initState();
//     _initChat();
//   }

  

//   Future<void> _initChat() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       String? citizenEmail = user?.email;

//       if (citizenEmail == null) {
//         print("User not logged in");
//         return;
//       }

//       // Step 1: Check if chat already exists
//       final query = await FirebaseFirestore.instance
//           .collection('chats')
//           .where('userEmail1', isEqualTo: citizenEmail)
//           .where('userEmail2', isEqualTo: governmentEmail)
//           .get();

//       String chatId;

//       if (query.docs.isNotEmpty) {
//         // Chat already exists
//         chatId = query.docs.first.id;
//       } else {
//         // Create a new chat
//         final chatDoc = await FirebaseFirestore.instance.collection('chats').add({
//           'userEmail1': citizenEmail,
//           'userEmail2': governmentEmail,
//           'createdAt': Timestamp.now(),
//         });
//         chatId = chatDoc.id;
//       }

//       // Navigate to message page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MessagePage(
//             chatId: chatId,
//             chatName: 'Government Chat',
//           ),
//         ),
//       );
//     } catch (e) {
//       print("Error initializing chat: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
// TODO: Update the import path below if your AuthProvider is located elsewhere
import '../providers/authProvider.dart';  // Your AuthProvider
import 'message_page.dart';

class CitizenMessageWrapper extends StatefulWidget {
  const CitizenMessageWrapper({Key? key}) : super(key: key);

  @override
  State<CitizenMessageWrapper> createState() => _CitizenMessageWrapperState();
}

class _CitizenMessageWrapperState extends State<CitizenMessageWrapper> {
  final String governmentEmail = 'government@nashra.com';

  @override
  void initState() {
    super.initState();
    _initChat();
  }
  Future<String?> getEmailByUid(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    return doc.data()?['email'];
  }
return null;
}

  Future<void> _initChat() async {
    try {
      // Get the current user email from AuthProvider
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      final userEmail = await getEmailByUid(auth.userId);


      if (userEmail == null) {
        print("User not logged in");
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('chats')
          .where('userEmail1', isEqualTo: userEmail)
          .where('userEmail2', isEqualTo: governmentEmail)
          .get();

      String chatId;

      if (query.docs.isNotEmpty) {
        chatId = query.docs.first.id;
      } else {
        final chatDoc = await FirebaseFirestore.instance.collection('chats').add({
          'userEmail1': userEmail,
          'userEmail2': governmentEmail,
          'createdAt': Timestamp.now(),
           'name': userEmail,
          //  'id': query.docs.first.id
        });
        // Now update the chat document to include its own ID
await FirebaseFirestore.instance.collection('chats').doc(chatDoc.id).update({
  'id': chatDoc.id,
});
        chatId = chatDoc.id;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MessagePage(
            chatId: chatId,
            chatName: 'Government Chat',
            senderemail: userEmail,
          ),
        ),
      );
    } catch (e) {
      print("Error initializing chat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
