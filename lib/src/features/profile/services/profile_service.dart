import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Get user profile stream
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Get user profile future
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Create or update user profile
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
    File? profileImage,
  }) async {
    String? photoURL;
    
    if (profileImage != null) {
      photoURL = await _uploadProfileImage(uid, profileImage);
      data['photoURL'] = photoURL;
    }

    await _users.doc(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // Upload profile image
  Future<String> _uploadProfileImage(String uid, File image) async {
    final storageRef = _storage.ref().child('profile_images/$uid.jpg');
    
    // Compress image before uploading
    final uploadTask = storageRef.putFile(
      image,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': uid},
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Create initial profile after social auth
  Future<void> createInitialProfile(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'authProvider': credential.credential?.signInMethod,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSignIn': FieldValue.serverTimestamp(),
      'isProfileComplete': false,
    };

    await _users.doc(user.uid).set(
      userData,
      SetOptions(merge: true),
    );
  }

  // Update user preferences
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences) async {
    await _users.doc(uid).update({
      'preferences': preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark profile as complete
  Future<void> markProfileComplete(String uid) async {
    await _users.doc(uid).update({
      'isProfileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete profile
  Future<void> deleteProfile(String uid) async {
    // Delete profile image if exists
    try {
      final storageRef = _storage.ref().child('profile_images/$uid.jpg');
      await storageRef.delete();
    } catch (e) {
      // Image might not exist
    }

    // Delete user document
    await _users.doc(uid).delete();
  }

  // Update last sign in
  Future<void> updateLastSignIn(String uid) async {
    await _users.doc(uid).update({
      'lastSignIn': FieldValue.serverTimestamp(),
    });
  }

  // Get profile completion status
  Future<bool> isProfileComplete(String uid) async {
    final doc = await _users.doc(uid).get();
    return (doc.data() as Map<String, dynamic>?)?['isProfileComplete'] ?? false;
  }
}