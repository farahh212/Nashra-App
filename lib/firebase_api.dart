import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';


Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Handle background message
  print("Titke${message.notification?.title}");
  print("Body${message.notification?.body}");
  print('Payload: ${message.data}');
}

class FirebaseAPi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage message) {
    // Handle the message as needed, e.g., print or process data
    print("Handled message: ${message.notification?.title}");
    print("Handled message body: ${message.notification?.body}");
    print("Handled message data: ${message.data}");
  }

  // final _androidChannel = const AndroidNotificationChannel(
  //   'high_importance_channel',
  //   'High Importance Notifications',
  //   description: 'This channel is used for important notifications.',
  //   importance: Importance.defaultImportance,
  // );

  // Future initLocalNotifications() async {
  //   final initializationSettingsAndroid =
  //       AndroidInitializationSettings('@drawable/ic_launcher');
  //   final settings =
  //       InitializationSettings(android: initializationSettingsAndroid);
  //   await _localNotifications.initialize(
  //     settings,
  //     onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
  //       final payload = notificationResponse.payload;
  //       if (payload != null) {
  //         final message = RemoteMessage.fromMap(jsonDecode(payload));
  //         handleMessage(message);
  //       }
  //     }
  //   );
  //   final platform =_localNotifications.resolvePlatformSpecificImplementation<
  //       AndroidFlutterLocalNotificationsPlugin>();
  //   await platform?.createNotificationChannel(_androidChannel);
  // }

// final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> iniNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fCMToken");
}
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

//     FirebaseMessaging.onMessage.listen((message) {
//       // Handle foreground message
//       final notification = message.notification;
//       if (notification ==null) return;

//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             _androidChannel.id,
//             _androidChannel.name,
//             channelDescription: _androidChannel.description,
//              icon: '@drawable/ic_launcher',
//           ),
//         ),
//         payload: jsonEncode(message.toMap()), 
//       );

//     });
//   }
}