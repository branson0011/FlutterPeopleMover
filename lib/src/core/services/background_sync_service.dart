import 'dart:async';
import 'package:shared_preferences.dart';
import '../database/repositories/interaction_tracking_repository.dart';

class BackgroundSyncService {
  static const String _lastSyncKey = 'last_interaction_sync';
  final InteractionTrackingRepository _repository;
  final SharedPreferences _prefs;
  Timer? _syncTimer;

  BackgroundSyncService(this._repository, this._prefs);

  void startSync({Duration interval = const Duration(minutes: 15)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => _performSync());
  }

  Future<void> _performSync() async {
    try {
      final lastSync = _prefs.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Prune old interactions
      await _repository.pruneOldInteractions(const Duration(days: 30));

      // Update last sync time
      await _prefs.setInt(_lastSyncKey, now);
    } catch (e) {
      print('Error during interaction sync: $e');
    }
  }

  void stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
