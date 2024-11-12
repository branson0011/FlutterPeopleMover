import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  // Initialize profile stream
  void initializeProfileStream(String uid) {
    _profileService.getUserProfileStream(uid).listen((profile) {
      _profile = profile;
      notifyListeners();
    });
  }

  // Update profile
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
    File? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateProfile(
        uid: uid,
        data: data,
        profileImage: profileImage,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update preferences
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updatePreferences(uid, preferences);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check profile completion
  Future<bool> checkProfileCompletion(String uid) async {
    return await _profileService.isProfileComplete(uid);
  }

  // Mark profile as complete
  Future<void> completeProfile(String uid) async {
    await _profileService.markProfileComplete(uid);
  }
}