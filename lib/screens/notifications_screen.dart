




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  // void dispose() {
  //   // ✅ Called when the user leaves the screen
  //   final auth = Provider.of<AuthProvider>(context, listen: false);
  //   getEmailByUid(auth.userId).then((email) {
  //     markAllNotificationsAsRead(email);
  //   });
  //   super.dispose();
  // }
  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> deleteAllNotifications(String email) async {
    try {
      final snapshots = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userEmail', isEqualTo: email)
          .get();

      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  Future<String> getEmailByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['email'] != null) {
      return doc.data()?['email'];
    }
    return 'government@nashra.com'; // default fallback
  }

  Stream<List<Map<String, dynamic>>> getUserNotifications(String email) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userEmail', isEqualTo: email)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList());
       
  }

  Future<void> markAllNotificationsAsRead(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('notifications')
      .where('userEmail', isEqualTo: email)
      .where('isRead', isEqualTo: false)
      .get();

  for (var doc in snapshot.docs) {
    await doc.reference.update({'isRead': true});
  }
}

  

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications",style: TextStyle(color: Colors.white)),
        backgroundColor: const Color((0xFF1976D2)),
        foregroundColor: Colors.white,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back,color: Colors.white),
    onPressed: () async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = await getEmailByUid(auth.userId);
    await markAllNotificationsAsRead(email);
    Navigator.pop(context);
    },
  ),
        actions: [
          FutureBuilder<String>(
            future: getEmailByUid(auth.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              final userEmail = snapshot.data!;
              return TextButton(
                onPressed: () => deleteAllNotifications(userEmail),
                child: const Text(
                  "Clear All",
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<String>(
        future: getEmailByUid(auth.userId),
        builder: (context, emailSnapshot) {
          if (emailSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (emailSnapshot.hasError) {
            return Center(child: Text('Error: ${emailSnapshot.error}'));
          }

          final userEmail = emailSnapshot.data!;
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
                  final notificationId = notification['id'] ?? '';
                  final title = notification['title'] ?? 'No Title';
                  final body = notification['description'] ?? '';
                  //final timestamp = notification['createdAt']?.toDate();
                  final rawTimestamp = notification['createdAt'];
final timestamp = rawTimestamp != null
    ? DateFormat('yyyy-MM-dd – HH:mm').format(rawTimestamp.toDate())
    : 'No date';

                  return Dismissible(
                    key: Key(notificationId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      deleteNotification(notificationId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification deleted')),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: const Color(0xFFF0F9F1),
                      elevation: 5,
                      shadowColor: Color(0xFF1976D2),
                      child: ListTile(
                        leading: const Icon(Icons.notifications, color: Color(0xFF1976D2), size: 32),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(body, style: TextStyle(color: Colors.black.withOpacity(0.7))),
                            if (timestamp != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '$timestamp',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
