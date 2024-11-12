import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

enum BiometricType {
  fingerprint,
  face,
  iris,
  undefined
}

enum BiometricStrength {
  none,
  weak,
  medium,
  strong
}

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _biometricStorageKey = 'biometric_credentials';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricStrengthKey = 'biometric_strength';

  // Platform-specific configurations
  final Map<String, dynamic> _iosConfig = {
    'biometricOnly': true,
    'sensitiveTransaction': true,
    'useErrorDialogs': true,
    'stickyAuth': true,
  };

  final Map<String, dynamic> _androidConfig = {
    'biometricOnly': true,
    'sensitiveTransaction': true,
    'useErrorDialogs': true,
    'stickyAuth': true,
    'invalidateOnEnrollment': true,
  };

  // Platform-specific biometric strength requirements
  final Map<String, int> _biometricStrengthRequirements = {
    'ios': BiometricStrength.strong.index,
    'android': BiometricStrength.medium.index,
  };

  Future<Map<String, bool>> getAvailableBiometricTypes() async {
    try {
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      return {
        'canCheckBiometrics': await _localAuth.canCheckBiometrics,
        'isDeviceSupported': await _localAuth.isDeviceSupported(),
        'hasFaceID': availableBiometrics.contains(BiometricType.face),
        'hasFingerprint': availableBiometrics.contains(BiometricType.fingerprint),
        'hasIris': availableBiometrics.contains(BiometricType.iris),
      };
    } on PlatformException catch (_) {
      return {
        'canCheckBiometrics': false,
        'isDeviceSupported': false,
        'hasFaceID': false,
        'hasFingerprint': false,
        'hasIris': false,
      };
    }
  }

  Future<BiometricStrength> checkBiometricStrength() async {
    try {
      final biometricTypes = await getAvailableBiometricTypes();
      
      if (Platform.isIOS && biometricTypes['hasFaceID'] == true) {
        return BiometricStrength.strong;
      } else if (biometricTypes['hasFingerprint'] == true) {
        if (Platform.isIOS) {
          return BiometricStrength.strong;
        } else {
          // Check Android API level for biometric strength
          if (await _isStrongBiometric()) {
            return BiometricStrength.strong;
          } else {
            return BiometricStrength.medium;
          }
        }
      } else if (biometricTypes['hasIris'] == true) {
        return BiometricStrength.strong;
      }
      
      return BiometricStrength.none;
    } catch (_) {
      return BiometricStrength.none;
    }
  }

  Future<bool> _isStrongBiometric() async {
    // Implementation would check Android API level and biometric class
    // This is a simplified version
    return Platform.isAndroid && await _isAndroidApiLevel28OrHigher();
  }

  Future<bool> _isAndroidApiLevel28OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 28;
    }
    return false;
  }

  Future<bool> authenticate() async {
    try {
      final biometricStrength = await checkBiometricStrength();
      final requiredStrength = Platform.isIOS 
          ? _biometricStrengthRequirements['ios']! 
          : _biometricStrengthRequirements['android']!;

      if (biometricStrength.index < requiredStrength) {
        throw BiometricException(
          'Biometric security level does not meet minimum requirements'
        );
      }

      final authOptions = Platform.isIOS 
          ? _iosConfig 
          : _androidConfig;

      return await _localAuth.authenticate(
        localizedReason: _getLocalizedReason(),
        options: AuthenticationOptions(
          stickyAuth: authOptions['stickyAuth'] as bool,
          biometricOnly: authOptions['biometricOnly'] as bool,
          useErrorDialogs: authOptions['useErrorDialogs'] as bool,
          sensitiveTransaction: authOptions['sensitiveTransaction'] as bool,
        ),
      );
    } on PlatformException catch (e) {
      throw _handleBiometricException(e);
    }
  }

  String _getLocalizedReason() {
    if (Platform.isIOS) {
      return 'Authenticate using Face ID or Touch ID';
    } else {
      return 'Authenticate using fingerprint or face recognition';
    }
  }

  Exception _handleBiometricException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricException('Biometric authentication is not available');
      case 'NotEnrolled':
        return BiometricException('No biometrics are enrolled on this device');
      case 'LockedOut':
        return BiometricException(
          'Too many failed attempts. Please try again later'
        );
      case 'PermanentlyLockedOut':
        return BiometricException(
          'Biometric authentication is permanently locked. Please use fallback authentication'
        );
      default:
        return BiometricException(e.message ?? 'Authentication failed');
    }
  }

  // Fallback authentication methods
  Future<bool> authenticateWithFallback() async {
    if (Platform.isIOS) {
      return await _authenticateWithPasscode();
    } else {
      return await _authenticateWithPattern();
    }
  }

  Future<bool> _authenticateWithPasscode() async {
    // Implementation would integrate with iOS device passcode
    // This is a placeholder for the actual implementation
    return await _localAuth.authenticate(
      localizedReason: 'Please enter your device passcode',
      options: const AuthenticationOptions(
        biometricOnly: false,
      ),
    );
  }

  Future<bool> _authenticateWithPattern() async {
    // Implementation would integrate with Android device pattern/PIN
    // This is a placeholder for the actual implementation
    return await _localAuth.authenticate(
      localizedReason: 'Please enter your device pattern or PIN',
      options: const AuthenticationOptions(
        biometricOnly: false,
      ),
    );
  }

    // Credential storage and management methods
  Future<void> storeBiometricCredentials({
    required String userId,
    required String provider,
    required Map<String, dynamic> credentials,
  }) async {
    try {
      // Generate encryption key
      final encryptionKey = _generateEncryptionKey();
      
      // Prepare data for storage
      final data = {
        'userId': userId,
        'provider': provider,
        'credentials': credentials,
        'timestamp': DateTime.now().toIso8601String(),
        'encryptionKey': encryptionKey,
        'biometricStrength': (await checkBiometricStrength()).index,
      };

      // Encrypt and store data
      final encryptedData = _encrypt(jsonEncode(data), encryptionKey);
      await _secureStorage.write(
        key: _getStorageKey(userId),
        value: encryptedData,
      );

      // Store biometric enabled flag
      await _secureStorage.write(
        key: _getEnabledKey(userId),
        value: 'true',
      );

      // Store biometric strength
      await storeBiometricStrength(userId);
    } catch (e) {
      throw BiometricException('Failed to store credentials: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getBiometricCredentials(String userId) async {
    try {
      // Check if biometrics are enabled for this user
      final isEnabled = await isBiometricsEnabled(userId);
      if (!isEnabled) return null;

      // Get encrypted data
      final encryptedData = await _secureStorage.read(
        key: _getStorageKey(userId),
      );
      if (encryptedData == null) return null;

      // Get stored data with encryption key
      final storedData = jsonDecode(encryptedData) as Map<String, dynamic>;
      final encryptionKey = storedData['encryptionKey'] as String;

      // Verify biometric strength hasn't been downgraded
      final storedStrength = BiometricStrength.values[storedData['biometricStrength'] as int];
      final currentStrength = await checkBiometricStrength();
      if (currentStrength.index < storedStrength.index) {
        await disableBiometrics(userId);
        throw BiometricException('Biometric security level has been downgraded');
      }

      // Decrypt and return credentials
      final decryptedData = _decrypt(encryptedData, encryptionKey);
      return jsonDecode(decryptedData) as Map<String, dynamic>;
    } catch (e) {
      throw BiometricException('Failed to retrieve credentials: ${e.toString()}');
    }
  }

  Future<void> enableBiometrics(String userId) async {
    try {
      final biometricStrength = await checkBiometricStrength();
      final requiredStrength = Platform.isIOS 
          ? _biometricStrengthRequirements['ios']! 
          : _biometricStrengthRequirements['android']!;

      if (biometricStrength.index < requiredStrength) {
        throw BiometricException(
          'Biometric security level does not meet minimum requirements'
        );
      }

      await _secureStorage.write(
        key: _getEnabledKey(userId),
        value: 'true',
      );
    } catch (e) {
      throw BiometricException('Failed to enable biometrics: ${e.toString()}');
    }
  }

  Future<void> disableBiometrics(String userId) async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _getStorageKey(userId)),
        _secureStorage.delete(key: _getEnabledKey(userId)),
        _secureStorage.delete(key: '${_biometricStrengthKey}_$userId'),
      ]);
    } catch (e) {
      throw BiometricException('Failed to disable biometrics: ${e.toString()}');
    }
  }

  Future<bool> isBiometricsEnabled(String userId) async {
    try {
      final value = await _secureStorage.read(key: _getEnabledKey(userId));
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  Future<void> clearBiometricData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw BiometricException('Failed to clear biometric data: ${e.toString()}');
    }
  }

  Future<void> validateAndRefreshCredentials(String userId) async {
    try {
      final isValid = await validateStoredCredentials(userId);
      if (!isValid) {
        await disableBiometrics(userId);
        throw BiometricException('Stored credentials have expired');
      }

      // Refresh credentials if they're more than 15 days old
      final credentials = await getBiometricCredentials(userId);
      if (credentials != null) {
        final timestamp = DateTime.parse(credentials['timestamp'] as String);
        final now = DateTime.now();
        if (now.difference(timestamp).inDays > 15) {
          await refreshCredentials(userId);
        }
      }
    } catch (e) {
      throw BiometricException('Credential validation failed: ${e.toString()}');
    }
  }

  Future<void> refreshCredentials(String userId) async {
    try {
      final credentials = await getBiometricCredentials(userId);
      if (credentials != null) {
        await storeBiometricCredentials(
          userId: userId,
          provider: credentials['provider'] as String,
          credentials: credentials['credentials'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      throw BiometricException('Failed to refresh credentials: ${e.toString()}');
    }
  }

  Future<bool> validateStoredCredentials(String userId) async {
    try {
      final credentials = await getBiometricCredentials(userId);
      if (credentials == null) return false;

      final timestamp = DateTime.parse(credentials['timestamp'] as String);
      final now = DateTime.now();
      
      // Check if credentials are not older than 30 days
      return now.difference(timestamp).inDays <= 30;
    } catch (e) {
      return false;
    }
  }

   // Add biometric strength persistence
  Future<void> storeBiometricStrength(String userId) async {
    final strength = await checkBiometricStrength();
    await _secureStorage.write(
      key: '${_biometricStrengthKey}_$userId',
      value: strength.index.toString(),
    );
  }

  Future<BiometricStrength> getStoredBiometricStrength(String userId) async {
    final strengthValue = await _secureStorage.read(
      key: '${_biometricStrengthKey}_$userId',
    );
    return BiometricStrength.values[int.parse(strengthValue ?? '0')];
  }
}