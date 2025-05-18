

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../services/notificationService.dart';

class MessagePage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String senderemail;
  //final String receiverEmail; // Add receiver's email

  const MessagePage({
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.senderemail
    //required this.receiverEmail, // Include receiver's email
  }) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = 'your_user_id'; // Replace with actual user logic
  late final String currentUserEmail = widget.senderemail; // Use senderemail from widget

  Stream<List<Message>> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Step 1: Send message to Firestore
    final messageRef = await FirebaseFirestore.instance.collection('messages').add({
      'chatId': widget.chatId,
      'senderId': currentUserEmail,
      'content': content,
      'createdAt': Timestamp.now(),
    });

  
    Future<String?> getFcmTokenByEmail(String email) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    final userDoc = querySnapshot.docs.first;
    return userDoc.data()['fcmToken'] as String?;
  }
  return null;
}

    // Step 2: Get the chat document to retrieve user emails
    final chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    if (!chatSnapshot.exists) {
      return; // Handle error or non-existent chat
    }

    final chatData = chatSnapshot.data()!;
    final userEmail1 = chatData['userEmail1'];
    final userEmail2 = chatData['userEmail2'];

    // Step 3: Determine the recipient (the other user who didn't send the message)
    String recipientEmail = '';
    if (userEmail1 != currentUserEmail) {
      recipientEmail = userEmail1;
    } else if (userEmail2 != currentUserEmail) {
      recipientEmail = userEmail2;
    }

    await FirebaseFirestore.instance.collection('notifications').add({
    'title': 'New Message',
    'description': 'You have a new message from $currentUserEmail',
    'userEmail': recipientEmail,
    'isRead': false,
    'createdAt': Timestamp.now(),
  });
    
  final fcm = await getFcmTokenByEmail(recipientEmail);
  final String? fcmToken = fcm;
  if (fcmToken != null && fcmToken.isNotEmpty) {
    await sendPushNotification(
      fcmToken,
      'New message from $currentUserEmail',
      content,
    );
  }
    // Clear the message input field after sending the message
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color.fromARGB(255, 188, 217, 189),
        elevation: 2,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 151, 191, 151),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(widget.chatName, style: const TextStyle(color: Colors.black)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 255, 223),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages found.'));
                }

                final messages = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message.senderId == currentUserEmail;

                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSender
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isSender ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${message.createdAt.toLocal()}',
                                style: TextStyle(
                                  color: isSender ? Colors.white70 : Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

