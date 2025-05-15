

import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/poll.dart';
import 'package:http/http.dart' as http;


class Pollsprovider with ChangeNotifier{
  List<Poll> polls=[];

  Future<void> addPoll(Poll poll, String token) async {
    var pollsURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB.json?auth=$token');
  return http
    .post(pollsURL, body: json.encode({
      'question': poll.question,
      'options': poll.options,
      'createdAt': DateTime.now().toIso8601String(),
      'endDate': poll.endDate.toIso8601String(),
    })).then((response) {
      polls.add(Poll(
        id: json.decode(response.body)['name'],
        question: poll.question,
        options: poll.options,
        createdAt: DateTime.now(),
        endDate: poll.endDate,
      ));
    }).catchError((error) {
      print("Failed to add poll: $error");
      throw error;
    });


  }

  // Future<void> fetchPollsFromServer(String token) async {
  //   var pollsURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB.json?auth=$token');

  //   try {
  //     var response = await http.get(pollsURL);
  //     var fetchedData = json.decode(response.body) as Map<String, dynamic>;

  //     polls.clear();
  //     fetchedData.forEach((key, value) {
  //       polls.add(Poll(
  //         id: key,
  //         question: value['question'],
  //         options: List<String>.from(value['options']),
  //         createdAt: DateTime.parse(value['createdAt']),
  //         endDate: DateTime.parse(value['endDate']),
  //       ));
  //     });
  //   } catch (error) {
  //     print("Failed to fetch polls: $error");
  //     throw error;
  //   }
  // }
  Future<void> fetchPollsFromServer(String token) async {
  var pollsURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB.json?auth=$token');

  try {
    var response = await http.get(pollsURL);
    var fetchedData = json.decode(response.body) as Map<String, dynamic>;

    polls.clear();
    fetchedData.forEach((key, value) {
      polls.add(Poll.fromMap(key, {
        'question': value['question'],
        'options': value['options'],
        'votes': value['votes'] ?? {},
        'voterToOption': value['voterToOption'] ?? {},
        'createdAt': value['createdAt'],
        'endDate': value['endDate'],
        'imageUrl': value['imageUrl'],
      }));
    });
  } catch (error) {
    print("Failed to fetch polls: $error");
    throw error;
  }
}

  // Future<void> updateVotes(String pollId, String option, String token) async {
  //   var pollURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB/$pollId.json?auth=$token');

  //   try {


  //     var response = await http.patch(pollURL, body: json.encode({
  //       'votes': {option: (polls.firstWhere((poll) => poll.id == pollId).votes[option] ?? 0) + 1},
  //     }));
  //     if (response.statusCode == 200) {
  //       notifyListeners();
  //     } else {
  //       print("Failed to update votes: ${response.body}");
  //     }
  //   } catch (error) {
  //     print("Failed to update votes: $error");
  //     throw error;
  //   }
  // }

//  Future<void> updateVotes(String pollId, String option, String token) async {
//   final pollIndex = polls.indexWhere((poll) => poll.id == pollId);
//   if (pollIndex == -1) return;

//   final updatedVotes = {...polls[pollIndex].votes};
//   updatedVotes[option] = (updatedVotes[option] ?? 0) + 1;

//   var pollURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB/$pollId.json?auth=$token');

//   try {
//     await http.patch(pollURL, body: json.encode({
//       'votes': updatedVotes,
//     }));
    
//     // Update local state
//     polls[pollIndex] = polls[pollIndex].copyWith(votes: updatedVotes);
//     notifyListeners();
//   } catch (error) {
//     print("Failed to update votes: $error");
//     throw error;
//   }
// }
// Future<void> updateVotes(String pollId, String option, String token) async {
//   final pollIndex = polls.indexWhere((poll) => poll.id == pollId);
//   if (pollIndex == -1) return;

//   final poll = polls[pollIndex];
//   final updatedVotes = {...poll.votes};
  
//   // Only update the specific option's vote count
//   updatedVotes[option] = (updatedVotes[option] ?? 0) + 1;

//   var pollURL = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB/$pollId.json?auth=$token');

//   try {
//     await http.patch(pollURL, body: json.encode({
//       'votes': updatedVotes,
//     }));
    
//     // Update local state
//     polls[pollIndex] = poll.copyWith(votes: updatedVotes);
//     notifyListeners();
//   } catch (error) {
//     print("Failed to update votes: $error");
//     throw error;
//   }
// }

Future<void> updateVote({
  required String pollId,
  required String option,
  required String userId,
  required String token,
}) async {
  final pollIndex = polls.indexWhere((poll) => poll.id == pollId);
  if (pollIndex == -1) throw Exception('Poll not found');

  final poll = polls[pollIndex];
  if (poll.voterToOption.containsKey(userId)) {
    throw Exception('User already voted');
  }

  final updatedVotes = {...poll.votes};
  updatedVotes[option] = (updatedVotes[option] ?? 0) + 1;

  final updatedVoterToOption = {...poll.voterToOption};
  updatedVoterToOption[userId] = option;

  final url = Uri.parse('https://nahra-316ee-default-rtdb.europe-west1.firebasedatabase.app/PollsDB/$pollId.json?auth=$token');

  await http.patch(url, body: json.encode({
    'votes': updatedVotes,
    'voterToOption': updatedVoterToOption,
  }));

  polls[pollIndex] = poll.copyWith(
    votes: updatedVotes,
    voterToOption: updatedVoterToOption,
  );
  notifyListeners();
}
Map<String, double> calculatePercentages(String pollId) {
  final poll = polls.firstWhere((poll) => poll.id == pollId, orElse: () => throw Exception('Poll not found'));
  
  final totalVotes = poll.votes.values.fold(0, (sum, count) => sum + count);
  
  // If no votes, return 0% for all options
  if (totalVotes == 0) {
    return { for (var option in poll.options) option : 0.0 };
  }

  // Calculate percentages only for voted options
  final percentages = <String, double>{};
  for (var option in poll.options) {
    percentages[option] = (poll.votes[option] ?? 0) / totalVotes;
  }
  
  return percentages;
}

// Map<String, double> calculatePercentages(String pollId) {
//   final poll = polls.firstWhere((poll) => poll.id == pollId, orElse: () => throw Exception('Poll not found'));
  
//   final totalVotes = poll.votes.values.fold(0, (sum, count) => sum + count);
//   if (totalVotes == 0) {
//     // Return equal percentages if no votes yet
//     return Map.fromIterable(
//       poll.options,
//       key: (option) => option,
//       value: (_) => 1.0 / poll.options.length,
//     );
//   }

//   return Map.fromIterable(
//     poll.options,
//     key: (option) => option,
//     value: (option) => (poll.votes[option] ?? 0) / totalVotes,
//   );
// }


  

}