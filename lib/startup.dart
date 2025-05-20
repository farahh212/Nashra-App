import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart'; 
import 'signup.dart';
import 'utils/theme.dart';

class StartUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark 
                    ? [Color(0xFF64B5F6), Color(0xFF2196F3), Color(0xFF1976D2)]
                    : [Color(0xFF1976D2), Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'NASHRA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark 
                    ? [Color(0xFF64B5F6), Color(0xFF2196F3)]
                    : [Color(0xFF1976D2), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'A Platform for Every Voice in the City',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                  Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoginPage(authenticationMode: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide in from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  ),
);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                   Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoginPage(authenticationMode: 0),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide in from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  ),
);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Color(0xFF2196F3) : Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}