class AdminUser {
  final String uid;
  final String email;
  final String role;
  final Map<String, dynamic> permissions;
  final DateTime lastLogin;
  final List<String> managedVenues;
  final bool isActive;

  AdminUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.permissions,
    required this.lastLogin,
    required this.managedVenues,
    this.isActive = true,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      uid: map['uid'],
      email: map['email'],
      role: map['role'],
      permissions: Map<String, dynamic>.from(map['permissions']),
      lastLogin: map['lastLogin'].toDate(),
      managedVenues: List<String>.from(map['managedVenues'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'permissions': permissions,
      'lastLogin': lastLogin,
      'managedVenues': managedVenues,
      'isActive': isActive,
    };
  }
}
