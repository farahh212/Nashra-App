import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart'; // Ensure this exists
import 'package:firebase_app_check/firebase_app_check.dart';
import 'login.dart'; // Ensure this exists
import 'signup.dart'; // Ensure this exists
import 'startup.dart'; // Ensure this exists
import 'chat/ChatsPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use debug provider
    appleProvider: AppleProvider.debug,
  );

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nashra Project',
      home: ChatsPage(), // Change to SignUpPage to test Sign Up
    );
  }
}
