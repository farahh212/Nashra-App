import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/emergencyProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:nashra_project2/screens/advertisement_screen.dart';
import 'package:nashra_project2/screens/announcementCitizens/pollsScreen.dart';
import 'package:nashra_project2/screens/home.dart';
import 'firebase_options.dart';
import 'screens/notifications_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/app_localizations.dart';

import 'login.dart';
import 'startup.dart';
import 'screens/announcementCitizens/announcements.dart';

import 'package:nashra_project2/providers/authProvider.dart' as my_auth;
import 'package:provider/provider.dart';
import './providers/pollsProvider.dart';
import 'chat/ChatsPage.dart'; // Ensure this file contains the ChatPage class

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
        ChangeNotifierProvider(create: (_) => Announcementsprovider()),
        ChangeNotifierProvider(create: (_) => Pollsprovider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
         
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nashra Project',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        
        home:StartUp(), // Initial route logic
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        home: StartUp(), // Initial route logic
        routes: {
          
          '/advertisement': (context) => AdvertisementScreen(),
          '/announcements': (context) => Announcements(),
          '/polls':(context) => pollScreen(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomeScreen(),
          // Add more routes as needed
        },
      ),
    );
  }
}
