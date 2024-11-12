import 'package:firebase_auth/firebase_auth.dart';

class ErrorService {
  static String getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please provide a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Please provide a stronger password.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid login credentials.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  static String handleException(dynamic error) {
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error.code);
    }
    return error.toString();
  }
}