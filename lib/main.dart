import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:nashra_project2/providers/advertisementProvider.dart';
import 'package:nashra_project2/providers/announcementsProvider.dart';
import 'package:nashra_project2/providers/emergencyProvider.dart';
import 'package:nashra_project2/providers/pollsProvider.dart';
import 'package:nashra_project2/providers/languageProvider.dart';
import 'package:nashra_project2/screens/SplashScreen.dart';
import 'package:nashra_project2/screens/advertisement_screen.dart';
import 'package:nashra_project2/screens/analytics_screen.dart';
import 'package:nashra_project2/screens/announcementCitizens/pollsScreen.dart';
import 'package:nashra_project2/screens/emergency_screen.dart';
import 'package:nashra_project2/screens/gov_advertisments.dart';
import 'package:nashra_project2/screens/home.dart';
import 'package:nashra_project2/screens/reports/gov_reports_screen.dart';
import 'firebase_options.dart';
import 'screens/notifications_screen.dart';
import 'chat/messagePage_citiz.dart';
import 'package:nashra_project2/screens/reports/reports_screen.dart';
import 'login.dart';
import 'startup.dart';
import 'screens/announcementCitizens/announcements.dart';
import 'package:nashra_project2/providers/authProvider.dart' as my_auth;
import 'package:provider/provider.dart';
import './providers/pollsProvider.dart';
import 'chat/ChatsPage.dart'; 
import 'firebase_api.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAPi().iniNotifications();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdvertisementProvider()),
        ChangeNotifierProvider(create: (_) => Announcementsprovider()),
        ChangeNotifierProvider(create: (_) => Pollsprovider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Nashra Project',
            theme: Provider.of<ThemeProvider>(context).currentTheme.copyWith(
              appBarTheme: Provider.of<ThemeProvider>(context).currentTheme.appBarTheme.copyWith(
                centerTitle: true,
              ),
              drawerTheme: DrawerThemeData(
                scrimColor: Colors.black54,
              ),
              textTheme: Provider.of<ThemeProvider>(context).currentTheme.textTheme.apply(
                bodyColor: Provider.of<ThemeProvider>(context).currentTheme.textTheme.bodyLarge?.color,
                displayColor: Provider.of<ThemeProvider>(context).currentTheme.textTheme.displayLarge?.color,
              ),
              iconTheme: IconThemeData(
                color: Color(0xFF1976D2),
              ),
            ),
            locale: languageProvider.currentLocale,
            home: SplashScreen(),
            routes: {
              '/startup': (context) => StartUp(),
              '/reports': (context) => AllReports(),
              '/advertisement': (context) => AdvertisementScreen(),
              '/announcements': (context) => Announcements(),
              '/polls': (context) => pollScreen(),
              '/login': (context) => LoginPage(),
              '/home': (context) => HomeScreen(),
              '/message': (context) => CitizenMessageWrapper(),
              '/notifications': (context) => NotificationPage(),
              '/home': (context) => HomeScreen(),
              '/gov_advertisement': (context) => GovernmentAdvertisementsScreen(),
              '/reports': (context) => AllReports(),
              '/chats': (context) => CitizenMessageWrapper(),
              '/gov_chats': (context) => ChatsPage(),
              '/emergency': (context) => EmergencyNumbersScreen(),
              '/analytics': (context) => AnalyticsScreen(),
              '/govreports': (context)=> ViewReportsPage(),
            },
          );
        },
      ),
    ),
  );
}
