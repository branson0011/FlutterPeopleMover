import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  
  // Theme settings
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  
  // Language settings
  String get language => _prefs.getString('language') ?? 'en';
  
  // Notification settings
  bool get pushNotificationsEnabled => 
      _prefs.getBool('pushNotificationsEnabled') ?? true;
  bool get emailNotificationsEnabled =>
      _prefs.getBool('emailNotificationsEnabled') ?? true;
  
  // Location settings
  bool get locationServicesEnabled =>
      _prefs.getBool('locationServicesEnabled') ?? true;
  bool get backgroundLocationEnabled =>
      _prefs.getBool('backgroundLocationEnabled') ?? false;

  SettingsProvider(this._prefs);

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    await _prefs.setString('language', value);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool value) async {
    await _prefs.setBool('pushNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool value) async {
    await _prefs.setBool('emailNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setLocationServices(bool value) async {
    await _prefs.setBool('locationServicesEnabled', value);
    notifyListeners();
  }

  Future<void> setBackgroundLocation(bool value) async {
    await _prefs.setBool('backgroundLocationEnabled', value);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await Future.wait([
      _prefs.setBool('isDarkMode', false),
      _prefs.setString('language', 'en'),
      _prefs.setBool('pushNotificationsEnabled', true),
      _prefs.setBool('emailNotificationsEnabled', true),
      _prefs.setBool('locationServicesEnabled', true),
      _prefs.setBool('backgroundLocationEnabled', false),
    ]);
    notifyListeners();
  }
}
