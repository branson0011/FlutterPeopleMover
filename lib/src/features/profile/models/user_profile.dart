class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final Map<String, dynamic>? preferences;
  final String? authProvider; // 'google', 'apple', 'email'
  final DateTime? createdAt;
  final DateTime? lastSignIn;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.preferences,
    this.authProvider,
    this.createdAt,
    this.lastSignIn,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      preferences: map['preferences'],
      authProvider: map['authProvider'],
      createdAt: map['createdAt']?.toDate(),
      lastSignIn: map['lastSignIn']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'preferences': preferences,
      'authProvider': authProvider,
      'createdAt': createdAt,
      'lastSignIn': lastSignIn,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      preferences: preferences ?? this.preferences,
      authProvider: authProvider,
      createdAt: createdAt,
      lastSignIn: lastSignIn,
    );
  }
}