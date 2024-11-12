import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web Platform
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(authProvider);
      } else {
        // Mobile Platform
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      throw _handleSignInError(e);
    }
  }

  Exception _handleSignInError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return Exception('Account exists with different credentials.');
        case 'invalid-credential':
          return Exception('Invalid credentials.');
        case 'operation-not-allowed':
          return Exception('Google sign-in is not enabled.');
        case 'user-disabled':
          return Exception('User account has been disabled.');
        case 'user-not-found':
          return Exception('No user found.');
        default:
          return Exception('Authentication failed. Please try again.');
      }
    }
    return Exception('Unexpected error occurred.');
  }
}