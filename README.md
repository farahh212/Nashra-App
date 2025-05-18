# Nashra App

A Flutter application for community engagement and government services.

A few resources to get you started if this is your first Flutter project:
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Project Structure

```
lib/
├── models/           # Data models
│   ├── announcement.dart
│   ├── poll.dart
│   ├── message.dart
│   ├── chat.dart
│   ├── advertisement.dart
│   ├── report.dart
│   ├── emergency_number.dart
│   └── comment.dart
├── screens/          # UI screens
│   ├── login.dart
│   ├── signup.dart
│   └── startup.dart
├── services/         # Business logic and services
├── widgets/          # Reusable UI components
├── utils/           # Utility functions and constants
├── firebase_options.dart
└── main.dart
```

## Setup Instructions

1. Ensure you have Flutter installed and set up
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Configure Firebase:
   - Add your Firebase configuration in `firebase_options.dart`
   - Enable Authentication in Firebase Console
5. Run the app using `flutter run`

## Features

- User Authentication
- Community Announcements
- Polls and Surveys
- Emergency Contacts
- Chat System
- Advertisement Management
- Report Generation

## Dependencies

- Firebase Core
- Firebase Authentication
- Firebase App Check
- Flutter Material Design

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
