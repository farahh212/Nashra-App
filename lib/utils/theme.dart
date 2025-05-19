import 'package:flutter/material.dart';

//!!!!change the colors to match the Nashra style
//change what ever u want in this file to match the theme 
//all i did was start up i am not sure if this is correct or match the theme

class AppTheme {
  // Colors (Modern Blue Theme)
  static const Color primaryColor = Color(0xFF1A237E);     // Deep Indigo
  static const Color secondaryColor = Color(0xFF0D47A1);   // Dark Blue
  static const Color accentColor = Color(0xFF64B5F6);      // Light Blue
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1A237E);       // Deep Indigo
  static const Color textSecondaryColor = Color(0xFF0D47A1);     // Dark Blue
  static const Color textHintColor = Color(0xFFBDBDBD);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F7FA);  // Light Gray Blue
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFBDBDBD);

  static const Color deepCharcoal = Color(0xFF121212);
  static const Color darkSlate = Color(0xFF1E1E1E);
  static const Color electricBlue = Color(0xFF2962FF);    // Changed from purple
  static const Color softBlue = Color(0xFF42A5F5);        // Changed from cyan
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFFA0A0A0);
  static const Color vividRed = Color(0xFFEF4565);
  static const Color appBarDark = Color(0xFF1A237E);      // Changed to Deep Indigo
  static const Color iconColor = Color(0xFFF4F4F4);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1A237E),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1A237E),      // Deep Indigo
      secondary: const Color(0xFF42A5F5),     // Soft Blue
      error: vividRed,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimaryColor,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A237E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textSecondaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF1A237E),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF1A237E),
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepCharcoal,
    primaryColor: electricBlue,
    colorScheme: const ColorScheme.dark(
      primary: electricBlue,
      secondary: softBlue,
      error: vividRed,
      background: deepCharcoal,
      surface: darkSlate,
      onPrimary: lightGray,
      onSecondary: lightGray,
      onBackground: lightGray,
      onSurface: lightGray,
      onError: lightGray,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarDark,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor),
      titleTextStyle: TextStyle(
        color: lightGray,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightGray),
      bodyMedium: TextStyle(color: mediumGray),
      titleLarge: TextStyle(color: lightGray),
      titleMedium: TextStyle(color: lightGray),
    ),
    iconTheme: const IconThemeData(
      color: iconColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSlate,
      selectedItemColor: electricBlue,
      unselectedItemColor: mediumGray,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      color: darkSlate,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
