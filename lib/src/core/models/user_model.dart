import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final List<String> preferences;
  final GeoPoint location;
  final DateTime createdAt;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.preferences,
    required this.location,
    required this.createdAt,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'preferences': preferences,
      'location': location,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      preferences: List<String>.from(map['preferences']),
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      fcmToken: map['fcmToken'],
    );
  }
}
