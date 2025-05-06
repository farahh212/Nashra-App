class AppConstants {
  // App Information
  static const String appName = 'Nashra';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String announcementsCollection = 'announcements';
  static const String pollsCollection = 'polls';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  static const String advertisementsCollection = 'advertisements';
  static const String reportsCollection = 'reports';
  static const String emergencyNumbersCollection = 'emergency_numbers';
  static const String commentsCollection = 'comments';

  // Storage Paths
  static const String userImagesPath = 'users/images';
  static const String announcementImagesPath = 'announcements/images';
  static const String advertisementImagesPath = 'advertisements/images';
  static const String reportImagesPath = 'reports/images';
  static const String chatMediaPath = 'chats/media';

  // Shared Preferences Keys
  static const String userPrefsKey = 'user_preferences';
  static const String themePrefsKey = 'theme_preferences';
  static const String languagePrefsKey = 'language_preferences';
  static const String notificationPrefsKey = 'notification_preferences';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String permissionError = 'Permission denied.';
  static const String validationError = 'Please check your input.';

  // Success Messages
  static const String profileUpdateSuccess = 'Profile updated successfully.';
  static const String passwordResetSuccess = 'Password reset email sent.';
  static const String reportSubmittedSuccess = 'Report submitted successfully.';
  static const String announcementPostedSuccess = 'Announcement posted successfully.';
  static const String pollCreatedSuccess = 'Poll created successfully.';

  // Validation Messages
  static const String emailRequired = 'Email is required.';
  static const String passwordRequired = 'Password is required.';
  static const String nameRequired = 'Name is required.';
  static const String invalidEmail = 'Please enter a valid email.';
  static const String invalidPassword = 'Password must be at least 6 characters.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String phoneRequired = 'Phone number is required.';
  static const String invalidPhone = 'Please enter a valid phone number.';
} 