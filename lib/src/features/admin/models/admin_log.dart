class AdminLog {
  final String id;
  final String adminUid;
  final String action;
  final String targetType;
  final String targetId;
  final Map<String, dynamic> changes;
  final DateTime timestamp;
  final String? notes;

  AdminLog({
    required this.id,
    required this.adminUid,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.changes,
    required this.timestamp,
    this.notes,
  });

  factory AdminLog.fromMap(Map<String, dynamic> map) {
    return AdminLog(
      id: map['id'],
      adminUid: map['adminUid'],
      action: map['action'],
      targetType: map['targetType'],
      targetId: map['targetId'],
      changes: Map<String, dynamic>.from(map['changes']),
      timestamp: map['timestamp'].toDate(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminUid': adminUid,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'changes': changes,
      'timestamp': timestamp,
      'notes': notes,
    };
  }
}
