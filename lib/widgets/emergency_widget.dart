// Emergency Widget
// This file will contain emergency-related widgets and UI components 

import 'package:flutter/material.dart';
import '../models/emergency_number.dart';
import '../utils/theme.dart';

class EmergencyContactTile extends StatelessWidget {
  final EmergencyNumber contact;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const EmergencyContactTile({
    Key? key,
    required this.contact,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                '${contact.title}  ${contact.number}',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppTheme.errorColor),
              onPressed: onDelete,
            ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: onEdit,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
} 