import 'package:flutter/foundation.dart';
import '../services/admin_service.dart';
import '../models/admin_user.dart';
import '../models/admin_log.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  AdminUser? _currentAdmin;
  List<AdminLog> _logs = [];
  bool _isLoading = false;
  String? _error;

  AdminUser? get currentAdmin => _currentAdmin;
  List<AdminLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAdminUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentAdmin = await _adminService.getAdminUser(uid);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVenueStatus(String venueId, String status) async {
    try {
      if (_currentAdmin == null) throw Exception('No admin user logged in');
      
      _isLoading = true;
      notifyListeners();

      await _adminService.updateVenueStatus(
        _currentAdmin!.uid,
        venueId,
        status,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void startLogsListener() {
    _adminService.getAdminLogs().listen(
      (logs) {
        _logs = logs;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> sendNotification({
    required String targetAdminUid,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _adminService.sendAdminNotification(
        targetAdminUid: targetAdminUid,
        title: title,
        message: message,
        data: data,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
