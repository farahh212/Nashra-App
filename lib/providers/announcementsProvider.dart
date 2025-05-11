
import 'package:flutter/material.dart';
import 'package:nashra_project2/models/comment.dart';

import '../models/announcement.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Announcementsprovider with ChangeNotifier {
  List<Announcement> announcements = [
    // Announcement(createdAt: DateTime(2023, 10, 1), description: "This is a test announcement", id: "1", title: "Test Announcement", imageUrl: 'https://cu.edu.eg/ar/news/images/HdMjX1RKikA9hO2.jpg'),
    // Announcement(createdAt: DateTime(2023, 10, 2), description: "This is another test announcement", id: "2", title: "Another Test Announcement"),
    // Announcement(createdAt: DateTime(2023, 10, 3), description: "This is yet another test announcement", id: "3", title: "Yet Another Test Announcement"),
  ];

  // List<Announcement> get getAnnouncements {
  //   return announcements;
  // }

  // void addcommentToAnnouncement(String id, Comment comment){
  //   for (var announcement in announcements) {
  //     if (announcement.id == id) {
  //       announcement.comments.add(comment);
  //       notifyListeners();
  //       break;
  //     }
  //   }

  // }

  // List<Comment> getCommentByAnnouncementId(String id){
  //   return announcements.firstWhere((announcement) => announcement.id == id).comments;
  // } //list of comments of announcement

  // Announcement getAnnouncementById(String id) {
  //   return announcements.firstWhere((announcement) => announcement.id == id);
  // } // Get announcement by ID

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