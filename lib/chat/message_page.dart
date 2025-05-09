// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/message.dart';

// class MessagePage extends StatelessWidget {
//   final String chatId;

//   const MessagePage({Key? key, required this.chatId}) : super(key: key);

//   // Fetch messages from Firestore
//   Stream<List<Message>> getMessages(String chat) {
//      print("Fetching messages for chatId: $chat");
//     return FirebaseFirestore.instance
//         .collection('messages')
//         .where('chatId', isEqualTo: chat) // Filter messages by chatId
//         .orderBy('createdAt', descending: true) // Order messages by createdAt, descending
//         .snapshots()
//         .map((snapshot) {
//   print("Message snapshot with ${snapshot.docs.length} docs");
//   return snapshot.docs.map((doc) {
//     print("Message doc data: ${doc.data()}");
//     return Message.fromMap(doc.id, doc.data());
//   }).toList();
// });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Messages'),
//       ),
//       body: StreamBuilder<List<Message>>(
//         stream: getMessages(chatId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No messages found.'));
//           }

//           final messages = snapshot.data!;

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             child: ListView.builder(
//               reverse: true, // To show the latest messages at the bottom
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];

//                 // Build message bubbles
//                 return Align(
//                   alignment: message.senderId == 'your_user_id'
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft, // Your alignment logic
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       color: message.senderId == 'your_user_id'
//                           ? Colors.blueAccent
//                           : Colors.grey[300],
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: message.senderId == 'your_user_id'
//                               ? CrossAxisAlignment.end
//                               : CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               message.content,
//                               style: TextStyle(
//                                 color: message.senderId == 'your_user_id'
//                                     ? Colors.white
//                                     : Colors.black,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '${message.createdAt.toLocal()}',
//                               style: TextStyle(
//                                 color: message.senderId == 'your_user_id'
//                                     ? Colors.white70
//                                     : Colors.black45,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/message.dart';

// class MessagePage extends StatefulWidget {
//   final String chatId;
//   final String chatName; // Add this to pass the name of the chat

//   const MessagePage({Key? key, required this.chatId, required this.chatName})
//       : super(key: key);

//   @override
//   State<MessagePage> createState() => _MessagePageState();
// }

// class _MessagePageState extends State<MessagePage> {

//   final TextEditingController _messageController = TextEditingController();
//   final String currentUserId = 'your_user_id'; // Replace with actual user logic

//   Stream<List<Message>> getMessages(String chat) {
//     return FirebaseFirestore.instance
//         .collection('messages')
//         .where('chatId', isEqualTo: chat)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) =>
//             snapshot.docs.map((doc) => Message.fromMap(doc.id, doc.data())).toList());
//   }

//    Future<void> sendMessage() async {
//     final content = _messageController.text.trim();
//     if (content.isEmpty) return;

//     await FirebaseFirestore.instance.collection('messages').add({
//       'chatId': widget.chatId,
//       'senderId': currentUserId,
//       'content': content,
//       'createdAt': Timestamp.now(),
//     });

//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const currentUserId = 'your_user_id'; // Replace this with actual user logic

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         backgroundColor: const Color.fromARGB(255, 188, 217, 189),
//         elevation: 2,
//         title: Row(
          
//           mainAxisAlignment: MainAxisAlignment.start,
          
//           children: [
//             const CircleAvatar(
//               backgroundColor: Color.fromARGB(255, 151, 191, 151),
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             Text(
//               widget.chatName,
//               style: const TextStyle(color: Colors.black),
//             ),
            
//           ],
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: const Color.fromARGB(255, 241, 255, 223),
//       body: Container(
//         margin: const EdgeInsets.only(top: 0),
//         decoration: const BoxDecoration(
//           color: Color.fromARGB(255, 241, 255, 223),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: StreamBuilder<List<Message>>(
//           stream: getMessages(widget.chatId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text('No messages found.'));
//             }

//             final messages = snapshot.data!;

//             return Padding(
//               padding: const EdgeInsets.all(12),
//               child: ListView.builder(
//                 reverse: true,
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final message = messages[index];
//                   final isSender = message.senderId == currentUserId;

//                   return Align(
//                     alignment:
//                         isSender ? Alignment.centerRight : Alignment.centerLeft,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: isSender
//                             ? Colors.blueAccent
//                             : Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: isSender
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             message.content,
//                             style: TextStyle(
//                               color:
//                                   isSender ? Colors.white : Colors.black87,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '${message.createdAt.toLocal()}',
//                             style: TextStyle(
//                               color:
//                                   isSender ? Colors.white70 : Colors.black45,
//                               fontSize: 12,
//                             ),
//                           ),
                          
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
      
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessagePage extends StatefulWidget {
  final String chatId;
  final String chatName;

  const MessagePage({Key? key, required this.chatId, required this.chatName})
      : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = 'your_user_id'; // Replace with actual user logic

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
      'senderId': currentUserId,
      'content': content,
      'createdAt': Timestamp.now(),
    });

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
                      final isSender = message.senderId == currentUserId;

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

