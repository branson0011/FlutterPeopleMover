import 'package:flutter/foundation.dart';
import '../services/preference_service.dart';
import '../models/preference_settings.dart';

class PreferenceProvider with ChangeNotifier {
  final PreferenceService preferenceService = PreferenceService();
  PreferenceSettings? preferences;
  bool isLoading = false;
  String? error;

  PreferenceSettings? get userPreferences => preferences;
  bool get loading => isLoading;
  String? get errorMessage => error;

  Future<void> loadUserPreferences(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      preferenceService.getUserPreferences(userId).listen(
        (prefs) {
          preferences = prefs;
          notifyListeners();
        },
        onError: (error) {
          this.error = error.toString();
          notifyListeners();
        },
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserPreference(
    String userId,
    String key,
    dynamic value,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await preferenceService.updateSinglePreference(userId, key, value);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUserInterest(String userId, String interest) async {
    isLoading = true;
    notifyListeners();

    try {
      await preferenceService.addInterest(userId, interest);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeUserInterest(String userId, String interest) async {
    isLoading = true;
    notifyListeners();

    try {
      await preferenceService.removeInterest(userId, interest);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    error = null;
    notifyListeners();
  }
}
