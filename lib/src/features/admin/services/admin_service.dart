import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user.dart';
import '../models/admin_log.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Admin User Management
  Future<AdminUser?> getAdminUser(String uid) async {
    final documentSnapshot = await _firestore.collection('admin_users').doc(uid).get();
    if (documentSnapshot.exists) {
      return AdminUser.fromMap(documentSnapshot.data()!);
    }
    return null;
  }

  Future<void> createAdminUser(AdminUser admin) async {
    await _firestore.collection('admin_users').doc(admin.uid).set(admin.toMap());
    await _logAdminAction(
      adminUid: admin.uid,
      action: 'CREATE_ADMIN',
      targetType: 'admin_user',
      targetId: admin.uid,
      changes: admin.toMap(),
    );
  }

  // Venue Management
  Future<void> updateVenueStatus(String adminUid, String venueId, String status) async {
    await _firestore.collection('venues').doc(venueId).update({
      'status': status,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    
    await _logAdminAction(
      adminUid: adminUid,
      action: 'UPDATE_VENUE_STATUS',
      targetType: 'venue',
      targetId: venueId,
      changes: {'status': status},
    );
  }

  // Analytics
  Future<Map<String, dynamic>> getSystemAnalytics() async {
    // Implement analytics gathering
    return {};
  }

  // Logging
  Future<void> _logAdminAction({
    required String adminUid,
    required String action,
    required String targetType,
    required String targetId,
    required Map<String, dynamic> changes,
    String? notes,
  }) async {
    final adminLog = AdminLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      adminUid: adminUid,
      action: action,
      targetType: targetType,
      targetId: targetId,
      changes: changes,
      timestamp: DateTime.now(),
      notes: notes,
    );

    await _firestore.collection('admin_logs').add(adminLog.toMap());
  }

  Stream<List<AdminLog>> getAdminLogs() {
    return _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((documentSnapshot) => AdminLog.fromMap(documentSnapshot.data()))
            .toList());
  }

  // Notifications
  Future<void> sendAdminNotification({
    required String targetAdminUid,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('admin_notifications').add({
      'targetAdminUid': targetAdminUid,
      'title': title,
      'message': message,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
