import 'package:firebase_database/firebase_database.dart';
import '../models/poll.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PollService {
  final String _baseUrl = 'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app';
  final DatabaseReference _pollsRef = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/'
  ).ref().child('PollsDB');

  Future<Poll?> getPollById(String pollId) async {
    try {
      final snapshot = await _pollsRef.child(pollId).get();
      if (snapshot.exists) {
        return Poll.fromMap(pollId, Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      print('Error getting poll: $e');
      return null;
    }
  }

  Future<List<Poll>> getAllPolls() async {
    try {
      final snapshot = await _pollsRef.get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return Poll.fromMap(
          entry.key.toString(),
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    } catch (e) {
      print('Error getting polls: $e');
      return [];
    }
  }

  Future<void> voteOnPoll(String pollId, String option, String userId) async {
    try {
      final pollRef = _pollsRef.child(pollId);
      final snapshot = await pollRef.get();
      
      if (!snapshot.exists) {
        throw Exception('Poll does not exist');
      }

      final poll = Poll.fromMap(pollId, Map<String, dynamic>.from(snapshot.value as Map));
      
      // Remove previous vote if exists
      if (poll.voterToOption.containsKey(userId)) {
        final previousOption = poll.voterToOption[userId];
        if (previousOption != null) {
          poll.votes[previousOption] = (poll.votes[previousOption] ?? 1) - 1;
        }
      }

      // Add new vote
      poll.votes[option] = (poll.votes[option] ?? 0) + 1;
      poll.voterToOption[userId] = option;

      await pollRef.update({
        'votes': poll.votes,
        'voterToOption': poll.voterToOption,
      });
    } catch (e) {
      print('Error voting on poll: $e');
      throw e;
    }
  }
} 