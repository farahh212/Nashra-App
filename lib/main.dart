import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/screens/advertisement_screen.dart';
import 'firebase_options.dart';

import 'login.dart';
import 'startup.dart';
import 'screens/announcements.dart';

import 'package:nashra_project2/providers/authProvider.dart' as my_auth;
import 'package:provider/provider.dart';
import 'chat/ChatsPage.dart';

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
        ChangeNotifierProvider(create: (_) => AdvertisementProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nashra Project',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartUp(), // Initial route logic
        routes: {
          '/advertisement': (context) => AdvertisementScreen(),
          '/announcements': (context) => Announcements(),
          '/login': (context) => LoginPage(),
          // Add more routes as needed
        },
      ),
    );
  }
}
