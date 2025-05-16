import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPushMessage(String token, String title, String body) async {
  final serverKey = 'YOUR_FIREBASE_SERVER_KEY_HERE'; // From step 1

  final postUrl = 'https://fcm.googleapis.com/fcm/send';

  final data = {
    "to": token,
    "notification": {
      "title": title,
      "body": body,
      "sound": "default",
    },
    "priority": "high",
    "data": {
      // Optional: extra data you want to send
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
    },
  };

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final response = await http.post(
    Uri.parse(postUrl),
    body: jsonEncode(data),
    headers: headers,
  );

  if (response.statusCode == 200) {
    print('Push notification sent successfully');
  } else {
    print('Failed to send push notification: ${response.body}');
  }
}
