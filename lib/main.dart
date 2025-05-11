import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:nashra_project2/Sidebars/citizenSidebar.dart';
import 'firebase_options.dart'; // Ensure this file is generated using FlutterFire CLI
import 'login.dart'; // Ensure this exists
import 'package:nashra_project2/providers/authProvider.dart' as my_auth; //avoid duplicate imports
import 'package:provider/provider.dart';
import 'startup.dart'; // Ensure this exists
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/CitizenPages/announcements.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => Announcementsprovider()),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nashra Project',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartUp(),
        routes:{
          '/announcements': (context) => Announcements(),
          
        }
      ),
    );
  }
}
