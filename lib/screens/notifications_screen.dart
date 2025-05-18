// 

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';

class NotificationPage extends StatefulWidget {
  // final String userEmail;

  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    _initnotifcation();
  }
  // Stream<List<Map<String, dynamic>>> getUserNotifications(String email) {
  //   return FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where('userEmail', isEqualTo: email) // Filter by email
  //       .orderBy('createdAT', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) {
  //           final data = doc.data() as Map<String, dynamic>;
  //           data['id'] = doc.id; // 👈 Add Firestore document ID
  //           return data;
  //         }).toList());
  // }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  Future<String?> getEmailByUid(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    return doc.data()?['email'];
  }
return null;
}

  Future<void> _initnotifcation() async {
    try {
      // Get the current user email from AuthProvider
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      final userEmail = await getEmailByUid(auth.userId);

     // You can use userEmail here if needed, but do not return it.
     

     
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getUserNotifications(String email) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userEmail', isEqualTo: email) // Filter by email
        .orderBy('createdAT', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // 👈 Add Firestore document ID
            return data;
          }).toList());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String?>(
        future: getEmailByUid(auth.userId),
        builder: (context, emailSnapshot) {
          if (emailSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (emailSnapshot.hasError) {
            return Center(child: Text('Error: ${emailSnapshot.error}'));
          }
          final userEmail = emailSnapshot.data;
          if (userEmail == null) {
            return const Center(child: Text('No user email found.'));
          }
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: getUserNotifications(userEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No notifications found.'));
              }

              final notifications = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final notificationId = notification['id'] ?? '2';
                  print('Notification ID: $notificationId'); 
                  // Assuming each notification has a unique ID
                  final title = notification['title'] ?? 'No Title';
                  final body = notification['description'] ?? '';
                  final timestamp = notification['createdAT']?.toDate();

                  return Dismissible(
                    key: Key(notificationId), // Unique key for each item
                    direction: DismissDirection.endToStart, // Swipe from right to left
                    onDismissed: (direction) {
                      // Delete notification from Firestore
                      deleteNotification(notificationId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notification deleted')),
                      );
                    },
                    background: Container(
                      color: Colors.red, // Background color when swiped
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: const Color(0xFFF0F9F1),
                      elevation: 5,
                      shadowColor: Colors.green.withOpacity(0.4),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: Color(0xFF4CAF50), // Keep the green color
                          size: 32,
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              body,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                            if (timestamp != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  '${timestamp.toLocal()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
