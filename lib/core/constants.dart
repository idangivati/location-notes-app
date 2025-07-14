class AppConstants {
  // App Information
  static const String appName = 'Location Notes';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxNoteTitleLength = 100;
  static const int maxNoteBodyLength = 2000;
  
  // Location Constants
  static const Duration locationTimeout = Duration(seconds: 10);
  static const double defaultLatitude = 32.0853; // Tel Aviv
  static const double defaultLongitude = 34.7818; // Tel Aviv
  
  // Firestore Collections
  static const String notesCollection = 'notes';
  static const String userNotesSubCollection = 'userNotes';
  
  // Success Messages
  static const String signupSuccess = 'Account created successfully! Please sign in.';
  static const String noteCreatedSuccess = 'Note created successfully!';
  static const String noteUpdatedSuccess = 'Note updated successfully!';
  static const String noteDeletedSuccess = 'Note deleted successfully!';
  static const String locationAcquiredSuccess = 'Location acquired successfully!';
  
  // Error Messages
  static const String locationPermissionDenied = 'Location permissions are denied.';
  static const String locationPermissionPermanentlyDenied = 'Location permissions are permanently denied.';
  static const String locationRequiredError = 'Location is required to save notes';
  static const String userNotLoggedInError = 'User not logged in!';
  static const String genericError = 'An unexpected error occurred. Please try again.';
}