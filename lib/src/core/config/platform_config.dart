import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  // Minimum supported versions
  static const int minAndroidSdk = 21;
  static const String minIOSVersion = '12.0';
  
  // Feature flags
  static const bool enableBiometrics = true;
  static const bool enableLocationServices = true;
  static const bool enablePushNotifications = true;
  
  // API Keys
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Platform-specific settings
  static Map<String, dynamic> get platformSettings => {
    'ios': {
      'locationWhenInUsePermission': 'We need your location to show nearby venues',
      'locationAlwaysPermission': 'We use location for real-time updates',
      'faceIDPermission': 'Secure your account with Face ID',
    },
    'android': {
      'locationPermission': 'Location access is required for venue discovery',
      'biometricPrompt': 'Verify your identity',
    },
  };
}
