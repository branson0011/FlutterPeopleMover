import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<void> saveCredentials({
    required String userId,
    required String provider,
    required Map<String, dynamic> credentials,
  }) async {
    final data = {
      'provider': provider,
      'credentials': credentials,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _storage.write(
      key: 'biometric_auth_$userId',
      value: jsonEncode(data),
    );
  }

  Future<Map<String, dynamic>?> getCredentials(String userId) async {
    final data = await _storage.read(key: 'biometric_auth_$userId');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> deleteCredentials(String userId) async {
    await _storage.delete(key: 'biometric_auth_$userId');
  }
}