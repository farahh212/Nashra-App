import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: AppTheme.primaryColor, size: 28),
          Icon(Icons.notifications_outlined, color: AppTheme.primaryColor, size: 28),
          Icon(Icons.language, color: AppTheme.primaryColor, size: 28),
          Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
        ],
      ),
    );
  }
} 