import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Cloud Messaging
    await _initializeMessaging();
    
    // Configure Firestore settings
    await _configureFirestore();
  }

  static Future<void> _initializeMessaging() async {
    final messaging = FirebaseMessaging.instance;
    
    // Request permission for notifications
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get Firebase Cloud Messaging token
    final token = await messaging.getToken();
    print('Firebase Cloud Messaging Token: $token');
  }

  static Future<void> _configureFirestore() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
