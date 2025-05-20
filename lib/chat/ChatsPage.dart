

// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import '../models/chat.dart'; // Your Chat model
// // // import 'message_page.dart'; // Your MessagePage widget (assuming this is where the chat messages are displayed)

// // // class ChatsPage extends StatelessWidget {
// // //   const ChatsPage({super.key});

// // //   Stream<List<Chat>> getChats() {
// // //     return FirebaseFirestore.instance
// // //         .collection('chats')
// // //         .snapshots()
// // //         .map((snapshot) {
// // //           print("Got snapshot with ${snapshot.docs.length} docs");
// // //           return snapshot.docs.map((doc) {
// // //             print("Doc data: ${doc.data()}");
// // //             return Chat.fromMap(doc.data(), doc.id ,doc['name']);
// // //           }).toList();
// // //         });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Messages')),
// // //       body: StreamBuilder<List<Chat>>(
// // //         stream: getChats(),
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             return const Center(child: CircularProgressIndicator());
// // //           }
// // //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
// // //             return const Center(child: Text('No chats found.'));
// // //           }

// // //           final chats = snapshot.data!;

// // //           return ListView.builder(
// // //             itemCount: chats.length,
// // //             itemBuilder: (context, index) {
// // //               final chat = chats[index];

// // //               return Card(
// // //                 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// // //                 elevation: 4,
// // //                 shape: RoundedRectangleBorder(
// // //                   borderRadius: BorderRadius.circular(12),
// // //                 ),
// // //                 child: InkWell(
// // //                   onTap: () {
// // //                     Navigator.push(
// // //                       context,
// // //                       MaterialPageRoute(
// // //                         builder: (_) => MessagePage(chatId: chat.id),
// // //                       ),
// // //                     );
// // //                   },
// // //                   child: ListTile(
// // //                     contentPadding: const EdgeInsets.all(16),
// // //                     leading: CircleAvatar(
// // //                       radius: 30,
// // //                       backgroundColor: Colors.blueGrey,
// // //                       child: Icon(
// // //                         Icons.chat,
// // //                         color: Colors.white,
// // //                       ),
// // //                     ),
// // //                     title: Text(
// // //                       '${chat.name}',
// // //                       style: const TextStyle(fontWeight: FontWeight.bold),
// // //                     ),
// // //                     subtitle: Text(
// // //                       'Last message preview or description here',
// // //                       style: TextStyle(
// // //                         color: Colors.grey[600],
// // //                         fontStyle: FontStyle.italic,
// // //                       ),
// // //                     ),
// // //                     trailing: Text(
// // //                       '${chat.createdAt.toLocal().toString().split(' ')[0]}',
// // //                       style: TextStyle(
// // //                         color: Colors.grey[500],
// // //                         fontSize: 12,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               );
// // //             },
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../models/chat.dart';
// // import 'message_page.dart';

// // class ChatsPage extends StatelessWidget {
// //   const ChatsPage({super.key});

// //   Stream<List<Chat>> getChats() {
// //     return FirebaseFirestore.instance
// //         .collection('chats')
// //         .snapshots()
// //         .map((snapshot) {
// //           return snapshot.docs.map((doc) {
// //             return Chat.fromMap(doc.data(), doc.id, doc['name']);
// //           }).toList();
// //         });
// //   }

// //   Future<int> getUnreadCount(String chatId) async {
// //   final snapshot = await FirebaseFirestore.instance
// //       .collection('messages')
// //       .where('chatId', isEqualTo: chatId)
// //       .where('ieRead', isEqualTo: false)
// //       .get();

// //   return snapshot.docs.length;
// // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color.fromARGB(255, 241, 255, 223), // cream background
// //       appBar: AppBar(
// //         backgroundColor: const Color.fromARGB(255, 238, 255, 221),
// //         elevation: 0,
// //         automaticallyImplyLeading: false,
// //         title: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text('NASHRA' ,style: TextStyle(
// //                     fontSize: 30,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),), // make sure this asset exists
// //             IconButton(
// //               icon: const Icon(Icons.menu, color: Colors.black),
// //               onPressed: () {},
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 const Text(
// //                   'Messages',
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 Expanded(
// //                   flex: 2,
// //                   child: TextField(
// //                     decoration: InputDecoration(
// //                       hintText: 'Search',
// //                       isDense: true,
// //                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                       filled: true,
// //                       fillColor: const Color.fromARGB(255, 217, 227, 219),
// //                       prefixIcon: const Icon(Icons.search, size: 20),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide: const BorderSide(color: Colors.green),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             Expanded(
// //               child: StreamBuilder<List<Chat>>(
// //                 stream: getChats(),
// //                 builder: (context, snapshot) {
// //                   if (snapshot.connectionState == ConnectionState.waiting) {
// //                     return const Center(child: CircularProgressIndicator());
// //                   }
// //                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //                     return const Center(child: Text('No chats found.'));
// //                   }

// //                   final chats = snapshot.data!;

// //                   return ListView.builder(
// //                     itemCount: chats.length,
// //                     itemBuilder: (context, index) {
// //                       final chat = chats[index];

// //                       return Dismissible(
// //                         key: Key(chat.id),
// //                         direction: DismissDirection.endToStart,
// //                         background: Container(
// //                           padding: const EdgeInsets.symmetric(horizontal: 20),
// //                           color: Colors.red.shade100,
// //                           alignment: Alignment.centerRight,
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.end,
// //                             children: [
// //                               const Icon(Icons.delete, color: Colors.red),
// //                               const SizedBox(width: 8),
// //                               Text(chat.name, style: const TextStyle(color: Colors.red)),
// //                             ],
// //                           ),
// //                         ),
// //                         onDismissed: (direction) {
// //                           FirebaseFirestore.instance.collection('chats').doc(chat.id).delete();
// //                         },
// //                         child: GestureDetector(
// //                           onTap: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (_) => MessagePage(chatId: chat.id,chatName: chat.name, senderemail: 'government@nashra.com')
// //                               ),
// //                             );
// //                           },
// //                           child: Card(
// //                             margin: const EdgeInsets.symmetric(vertical: 6),
// //                             color:  const Color.fromARGB(255, 243, 255, 230),  
// //                             elevation: 2,
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                             child: Padding(
// //                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
// //                               child: Row(
// //                                 children: [
// //                                   const CircleAvatar(
// //                                     radius: 24,
// //                                     backgroundColor: Color.fromARGB(255, 158, 186, 158),
// //                                     child: Icon(Icons.person, color: Color.fromARGB(255, 220, 225, 217)),
// //                                   ),
// //                                   const SizedBox(width: 12),
// //                                   Expanded(
// //                                     child: Column(
// //                                       crossAxisAlignment: CrossAxisAlignment.start,
// //                                       children: [
// //                                         Text(
// //                                           chat.name,
// //                                           style: const TextStyle(
// //                                               fontWeight: FontWeight.bold, fontSize: 16),
// //                                         ),
// //                                         const SizedBox(height: 4),
// //                                         // const Text(
// //                                         //   "We'd love to have a weekly market in the com ..", // TODO: Replace with lastMessage
// //                                         //   style: TextStyle(color: Colors.grey),
// //                                         //   overflow: TextOverflow.ellipsis,
// //                                         // ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 10),
// //                                   Container(
// //                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.red,
// //                                       borderRadius: BorderRadius.circular(12),
// //                                     ),
// //                                     child: const Text(
// //                                       '3', // TODO: Replace with chat.unreadCount
// //                                       style: TextStyle(color: Colors.white, fontSize: 12),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/chat.dart';
// import 'message_page.dart';

// class ChatsPage extends StatelessWidget {
//   const ChatsPage({super.key});

//   Stream<List<Chat>> getChats() {
//     return FirebaseFirestore.instance
//         .collection('chats')
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             return Chat.fromMap(doc.data(), doc.id, doc['name']);
//           }).toList();
//         });
//   }

//   /// New: Fetch unread counts for multiple chats at once
//   Future<Map<String, int>> getUnreadCountsForChats(List<String> chatIds) async {
//     if (chatIds.isEmpty) return {};

//     final snapshot = await FirebaseFirestore.instance
//         .collection('messages')
//         .where('chatId', whereIn: chatIds)
//         .where('isRead', isEqualTo: false)
//         .get();

//     Map<String, int> counts = {};
//     for (var doc in snapshot.docs) {
//       final chatId = doc['chatId'] as String;
//       counts[chatId] = (counts[chatId] ?? 0) + 1;
//     }

//     // Ensure every chatId has an entry even if 0 unread
//     for (var id in chatIds) {
//       counts.putIfAbsent(id, () => 0);
//     }

//     return counts;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 241, 255, 223), // cream background
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 238, 255, 221),
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'NASHRA',
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.menu, color: Colors.black),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Messages',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const Spacer(),
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search',
//                       isDense: true,
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       filled: true,
//                       fillColor: const Color.fromARGB(255, 217, 227, 219),
//                       prefixIcon: const Icon(Icons.search, size: 20),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: Colors.green),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: StreamBuilder<List<Chat>>(
//                 stream: getChats(),
//                 builder: (context, chatSnapshot) {
//                   if (chatSnapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!chatSnapshot.hasData || chatSnapshot.data!.isEmpty) {
//                     return const Center(child: Text('No chats found.'));
//                   }

//                   final chats = chatSnapshot.data!;

//                   // Wrap ListView with FutureBuilder to get unread counts
//                   return FutureBuilder<Map<String, int>>(
//                     future: getUnreadCountsForChats(chats.map((c) => c.id).toList()),
//                     builder: (context, unreadSnapshot) {
//                       if (unreadSnapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       final unreadCounts = unreadSnapshot.data ?? {};

//                       return ListView.builder(
//                         itemCount: chats.length,
//                         itemBuilder: (context, index) {
//                           final chat = chats[index];
//                           final unreadCount = unreadCounts[chat.id] ?? 0;

//                           return Dismissible(
//                             key: Key(chat.id),
//                             direction: DismissDirection.endToStart,
//                             background: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 20),
//                               color: Colors.red.shade100,
//                               alignment: Alignment.centerRight,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   const Icon(Icons.delete, color: Colors.red),
//                                   const SizedBox(width: 8),
//                                   Text(chat.name, style: const TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                             onDismissed: (direction) {
//                               FirebaseFirestore.instance
//                                   .collection('chats')
//                                   .doc(chat.id)
//                                   .delete();
//                             },
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => MessagePage(
//                                       chatId: chat.id,
//                                       chatName: chat.name,
//                                       senderemail: 'government@nashra.com',
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Card(
//                                 margin: const EdgeInsets.symmetric(vertical: 6),
//                                 color: const Color.fromARGB(255, 243, 255, 230),
//                                 elevation: 2,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 12, horizontal: 10),
//                                   child: Row(
//                                     children: [
//                                       const CircleAvatar(
//                                         radius: 24,
//                                         backgroundColor:
//                                             Color.fromARGB(255, 158, 186, 158),
//                                         child: Icon(Icons.person,
//                                             color: Color.fromARGB(255, 220, 225, 217)),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               chat.name,
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             // You can add last message or other info here
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       if (unreadCount > 0)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8, vertical: 4),
//                                           decoration: BoxDecoration(
//                                             color: Colors.red,
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Text(
//                                             '$unreadCount',
//                                             style: const TextStyle(
//                                                 color: Colors.white, fontSize: 12),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import 'message_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  Stream<List<Chat>> getChats() {
    return FirebaseFirestore.instance
        .collection('chats')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id, doc['name']))
          .toList();
    });
  }

  Future<Map<String, int>> getUnreadCountsForChats(List<String> chatIds) async {
    if (chatIds.isEmpty) return {};
    final snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('chatId', whereIn: chatIds)
        .where('isRead', isEqualTo: false)
        .get();

    Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final chatId = doc['chatId'] as String;
      counts[chatId] = (counts[chatId] ?? 0) + 1;
    }

    for (var id in chatIds) {
      counts.putIfAbsent(id, () => 0);
    }

    return counts;
  }

@override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFF1976D2),
    body: Column(
      children: [
        // AppBar-like section
        Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messaging',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : null,
                  ),
                  prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : null),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F1F5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Chat list
        Expanded(
          child: Container(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: StreamBuilder<List<Chat>>(
              stream: getChats(),
              builder: (context, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!chatSnapshot.hasData || chatSnapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No chats found.',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                    ),
                  );
                }

                final chats = chatSnapshot.data!;

                return FutureBuilder<Map<String, int>>(
                  future: getUnreadCountsForChats(chats.map((c) => c.id).toList()),
                  builder: (context, unreadSnapshot) {
                    final unreadCounts = unreadSnapshot.data ?? {};

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final unreadCount = unreadCounts[chat.id] ?? 0;

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MessagePage(
                                  chatId: chat.id,
                                  chatName: chat.name,
                                  senderemail: 'government@nashra.com',
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1976D2),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            chat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Message preview goes here...",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "8:15 PM",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white38 : Colors.black45,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF64B5F6)
                                        : const Color(0xFF0A1732),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
}
