/// Constants and configuration values for the Location Tracker app
class AppConstants {
  // App Info
  static const String appName = 'Location Tracker';
  static const String appVersion = '1.0.0';

  // API Configuration
  /// Replace with your actual Google API key from Google Cloud Console
  /// Steps: https://console.cloud.google.com/ → Create project → Enable APIs
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  // Location Tracking
  static const double locationUpdateThreshold = 10.0; // meters
  static const double locationAccuracy = 100.0; // meters

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Location History
  static const int maxHistoryItems = 100;

  // Error Messages
  static const String errorLocationDisabled =
      'Location service is disabled. Please enable it in settings.';
  static const String errorPermissionDenied =
      'Location permission is required to track your location.';
  static const String errorUnknown =
      'An unknown error occurred. Please try again.';
  static const String errorGeocoding =
      'Unable to get address from coordinates. Please try again.';

  // Success Messages
  static const String successLocationUpdated = 'Location updated successfully';
  static const String successPermissionGranted = 'Location permission granted';
}
