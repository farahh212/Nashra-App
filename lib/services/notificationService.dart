
import 'dart:convert';
import 'package:http/http.dart' as http;
Future<void> sendPushNotification(String fcmToken, String title, String body) async {
  final url = Uri.parse('http://10.0.2.2:3000/send-notification');

  final payload = {
    'token': fcmToken,
    'title': title,
    'body': body,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}