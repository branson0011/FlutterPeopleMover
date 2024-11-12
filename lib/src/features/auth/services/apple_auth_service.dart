import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generates a random 32 byte string
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      // Generate nonce
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuthCredential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in with Firebase
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw _handleSignInError(e);
    }
  }

  Exception _handleSignInError(dynamic error) {
    if (error is SignInWithAppleAuthorizationException) {
      switch (error.code) {
        case AuthorizationErrorCode.canceled:
          return Exception('Sign in canceled by user');
        case AuthorizationErrorCode.failed:
          return Exception('Sign in failed');
        case AuthorizationErrorCode.invalidResponse:
          return Exception('Invalid response');
        case AuthorizationErrorCode.notHandled:
          return Exception('Sign in not handled');
        default:
          return Exception('An unknown error occurred');
      }
    }
    return Exception('Authentication failed. Please try again.');
  }
}