import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../services/notificationService.dart';
import '../utils/theme.dart'; // Import your theme file

class MessagePage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String senderemail;

  const MessagePage({
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.senderemail,
  }) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  late final String currentUserEmail = widget.senderemail;

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

    await FirebaseFirestore.instance.collection('messages').add({
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

    final chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    if (!chatSnapshot.exists) return;

    final chatData = chatSnapshot.data()!;
    final userEmail1 = chatData['userEmail1'];
    final userEmail2 = chatData['userEmail2'];

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
    if (fcm != null && fcm.isNotEmpty) {
      await sendPushNotification(
        fcm,
        'New message from $currentUserEmail',
        content,
      );
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(width: 8),
            Text(widget.chatName, style: theme.textTheme.titleMedium?.copyWith(color: theme.appBarTheme.titleTextStyle?.color ?? theme.textTheme.titleMedium?.color)),
          ],
        ),
        iconTheme: theme.iconTheme,
      ),
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
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isSender
                              ? theme.colorScheme.primary
                              : theme.cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isSender ? 18 : 0),
                            bottomRight: Radius.circular(isSender ? 0 : 18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isSender
                                    ? theme.colorScheme.onPrimary
                                    : theme.textTheme.bodyMedium?.color,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isSender
                                    ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                    : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: theme.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      hintText: 'Type your message...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor ?? (isDark ? Colors.grey[800] : Colors.grey[100]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      sendMessage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
