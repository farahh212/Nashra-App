
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/comment.dart';
import 'package:nashra_project2/providers/authProvider.dart';

import '../models/announcement.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Announcementsprovider with ChangeNotifier {
  List<Announcement> announcements = [
  
  ];

  

  Future<void> addAnnouncement(Announcement announcement, String token){
    var announcementsURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB.json?auth=$token');

   return http
   .post(announcementsURL, body: json.encode({
      'title': announcement.title,
      'description': announcement.description,
      'createdAt': DateTime.now().toIso8601String(),
      'imageUrl': announcement.imageUrl,
   })).then((response) {
      announcements.add(Announcement(
        id: json.decode(response.body)['name'],
        title: announcement.title,
        description: announcement.description,
        createdAt: DateTime.now(),
        imageUrl: announcement.imageUrl,
        likes: 0,
        likedByUser: [],
      ));
   }).catchError((error) {
      print("Failed to add announcement: $error");
      throw error;
    });
  }

  Future<void> fetchAnnouncementsFromServer(String token) async{
  
    var announcementsURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB.json?auth=$token');

    try{
      var response = await http.get(announcementsURL);
      var fetchedData = json.decode(response.body) as Map<String, dynamic>;

      announcements.clear();
      fetchedData.forEach((key, value) {
        announcements.add(Announcement(
          id: key,
          title: value['title'],
          description: value['description'],
          createdAt: DateTime.parse(value['createdAt']),
          imageUrl: value['imageUrl'],
          likes: value['likes'] ?? 0,
          likedByUser: List<String>.from(value['likedByUser'] ?? []),
        ));
      });
    } catch (error) {
      print("Failed to fetch announcements: $error");
    }
  }

  Future<void> fetchCommentsForAnnouncement(String announcementId, String token) async {
  final url = Uri.parse(
    'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB/$announcementId/comments.json?auth=$token',
  );

  try {
    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return;

    // Find the matching announcement
    final announcement = announcements.firstWhere((a) => a.id == announcementId);

    // Clear and load new comments
    announcement.comments.clear();
    data.forEach((commentId, commentData) {
      announcement.comments.add(Comment.fromMap(commentId, commentData));
    });

    notifyListeners();
  } catch (e) {
    print('Error fetching comments: $e');
    throw e;
  }
}

  Future<void> addCommentToAnnouncement(String announcementId, Comment comment, String token) async {
    final url = Uri.parse(
      'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB/$announcementId/comments.json?auth=$token',
    );

    try {
      final response = await http.post(url, body: json.encode(comment.toMap()));
      final newComment = Comment.fromMap(json.decode(response.body)['name'], comment.toMap());

      // Find the matching announcement
      final announcement = announcements.firstWhere((a) => a.id == announcementId);
      announcement.comments.add(newComment);

      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
      throw e;
    }
  }

  // Future<void> addLikeToAnnouncement(String announcementId, String token) async {
  //   final announcement = announcements.firstWhere((a) => a.id == announcementId);
  //   final newLikeCount = announcement.likes + 1;
  

  //   final url = Uri.parse(
  //     'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB/$announcementId.json?auth=$token',
  //   );

  //   try {
  //   if(announcement.likedByUser!.contains(token)){
  //     await http.patch(url, body: json.encode({'likes': newLikeCount}));
  //     announcement.likedByUser.add(token);
  //     announcement.likes = newLikeCount;
  //   }
  //   else{
  //     return;
  //   }
       
  //     notifyListeners();
  //   } catch (e) {
  //     // Use debugPrint for logging in Flutter
  //     debugPrint('Error adding like: $e');
  //     rethrow;
  //   }
  // }

  Future<void> addLikeToAnnouncement(String announcementId, String token, String userId) async {
  final announcement = announcements.firstWhere((a) => a.id == announcementId);
  
  // Check if user already liked this
  if (announcement.likedByUser.contains(userId)) {
    return; // User already liked this, do nothing
  }

  final newLikeCount = announcement.likes + 1;
  final url = Uri.parse(
    'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB/$announcementId.json?auth=$token',
  );

  try {
    await http.patch(url, body: json.encode({
      'likes': newLikeCount,
      'likedByUser': [...announcement.likedByUser, userId] // Add user to likedBy
    }));
    
    // Update local state
    announcement.likes = newLikeCount;
    announcement.likedByUser.add(userId);
    notifyListeners();
    
  } catch (e) {
    debugPrint('Error adding like: $e');
    rethrow;
  }
}

  Future<void> removeLikeFromAnnouncement(String announcementId, String token, String userId) async {
    final announcement = announcements.firstWhere((a) => a.id == announcementId);
    final newLikeCount = (announcement.likes ?? 0) - 1;

    final url = Uri.parse(
      'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB/$announcementId.json?auth=$token',
    );

    try {
      await http.patch(url, body: json.encode({'likes': newLikeCount}));
      
      
      // announcement.likes--;
      announcement.likes = newLikeCount;
      announcement.likedByUser.remove(userId); // Assuming token is the user ID
      
      notifyListeners();
    } catch (e) {
      print('Error removing like: $e');
      throw e;
    }
  }


  // Future<void> addToLikedByUsers(String announcementId, String userId, String token) async {
  //   final url = Uri.parse(
  //     'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/AnnouncementDB/$announcementId/likedByUsers.json?auth=$token',
  //   );

  //   try {
  //     await http.patch(url, body: json.encode({'likedByUsers': userId}));
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error adding to likedByUsers: $e');
  //     throw e;
  //   }
  // }

  




}

// Future<void> fetchIdeasFromServer(String token) async {
// var ideasURL = Uri.parse(‘ourDBURL/IdeasDB.json?auth=$token');
// try {
// var response = await http.get(ideasURL);

// var fetchedData = json.decode(response.body) as Map<String, dynamic>;
// _ideas.clear();
// fetchedData.forEach((key, value) {
// _ideas.add(Idea(
// id: key, ideaTitle: value['ideaTitle’], ideaBody: value['ideaBody’], userId: value['userId'])
// );});
// notifyListeners();
// } catch (err) {}
// }
