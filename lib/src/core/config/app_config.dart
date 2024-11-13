class AppConfig {
  static const String appName = 'People Mover';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.peoplemover.com';
  
  // Feature Flags
  static const bool enableBiometrics = true;
  static const bool enableSocialAuth = true;
  static const bool enableOfflineMode = true;
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Cache Configuration
  static const int maxCacheAge = 7; // days
  static const int maxCacheSize = 50; // MB
  
  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Security Configuration
  static const bool enforceSSL = true;
  static const int minPasswordLength = 8;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Location Configuration
  static const int locationUpdateInterval = 5000; // milliseconds
  static const double defaultLocationAccuracy = 50.0; // meters
}
