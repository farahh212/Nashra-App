import 'package:flutter/material.dart';

//!!!!change the colors to match the Nashra style
//change what ever u want in this file to match the theme 
//all i did was start up i am not sure if this is correct or match the theme

class AppTheme {
  // Colors (Modern Blue Theme)
  static const Color primaryColor = Color(0xFF1976D2);     // Dark Blue
  static const Color secondaryColor = Color(0xFF2196F3);   // Medium Blue
  static const Color accentColor = Color(0xFF64B5F6);      // Light Blue
  static const Color darkBlue = Color(0xFF0D47A1);         // Deep Dark Blue
  static const Color lightBlue = Color(0xFFBBDEFB);        // Very Light Blue
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1A237E);       // Deep Blue
  static const Color textSecondaryColor = Color(0xFF283593);     // Indigo
  static const Color textHintColor = Color(0xFFBDBDBD);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);  // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFBDBDBD);

  static const Color deepCharcoal = Color(0xFF121212);
  static const Color darkSlate = Color(0xFF1E1E1E);
  static const Color electricBlue = Color(0xFF2196F3);
  static const Color softBlue = Color(0xFF64B5F6);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFFA0A0A0);
  static const Color vividRed = Color(0xFFEF4565);
  static const Color appBarDark = Color(0xFF1A1A1A);
  static const Color iconColor = Color(0xFFF4F4F4);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: const Color(0xFFF5F5F5),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primaryColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accentColor,
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: secondaryColor,
      tertiary: primaryColor,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: accentColor),
      titleTextStyle: TextStyle(
        color: accentColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: accentColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: accentColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: accentColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(
      color: accentColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppTheme.darkTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == AppTheme.lightTheme ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _currentTheme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();
  }
}
