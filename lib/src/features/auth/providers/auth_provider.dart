import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/biometric/biometric_service.dart';
import '../models/auth_state.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricService _biometricService = BiometricService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<AuthState> signIn(String email, String password) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      return AuthState(
        status: AuthStatus.authenticated,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthState> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      _user = userCredential.user;

      return AuthState(
        status: AuthStatus.authenticated,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> signInWithGoogle({
    Map<String, dynamic>? cachedCredentials,
  }) async {
    try {
      _setLoading(true);

      if (cachedCredentials != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: cachedCredentials['accessToken'],
          idToken: cachedCredentials['idToken'],
        );
        return await _auth.signInWithCredential(credential);
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (await _biometricService.isBiometricsAvailable()) {
        await _biometricService.storeBiometricCredentials(
          userId: userCredential.user!.uid,
          provider: 'google',
          credentials: {
            'accessToken': googleAuth.accessToken,
            'idToken': googleAuth.idToken,
          },
        );
      }

      return userCredential;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> signInWithApple({
    Map<String, dynamic>? cachedCredentials,
  }) async {
    try {
      _setLoading(true);

      if (cachedCredentials != null) {
        final AuthCredential credential = OAuthProvider('apple.com').credential(
          idToken: cachedCredentials['idToken'],
          accessToken: cachedCredentials['accessToken'],
        );
        return await _auth.signInWithCredential(credential);
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      _user = userCredential.user;

      if (await _biometricService.isBiometricsAvailable()) {
        await _biometricService.storeBiometricCredentials(
          userId: userCredential.user!.uid,
          provider: 'apple',
          credentials: {
            'idToken': appleCredential.identityToken,
            'accessToken': appleCredential.authorizationCode,
          },
        );
      }

      return userCredential;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _user = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  AuthState _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        message = 'Please provide a valid email address.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      case 'weak-password':
        message = 'Please provide a stronger password.';
        break;
      default:
        message = 'An error occurred. Please try again.';
    }
    _setError(message);
    return AuthState(
      status: AuthStatus.error,
      error: message,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}