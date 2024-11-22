import 'package:shared_preferences.dart';
import 'dart:math';

class ABTestingService {
  final SharedPreferences sharedPreferences;
  static const String testGroupKey = 'ab_test_group';
  static const String testVersionKey = 'ab_test_version';

  ABTestingService(this.sharedPreferences);

  Future<String> getTestGroup(String userId) async {
    final existingGroup = sharedPreferences.getString('${testGroupKey}_$userId');
    if (existingGroup != null) return existingGroup;

    final random = Random();
    final group = random.nextDouble() < 0.5 ? 'A' : 'B';
    await sharedPreferences.setString('${testGroupKey}_$userId', group);
    return group;
  }

  Future<void> logTestResult({
    required String userId,
    required String testName,
    required Map<String, dynamic> metrics,
  }) async {
    final group = await getTestGroup(userId);
    final version = sharedPreferences.getInt(testVersionKey) ?? 1;

    // Log test results to analytics
    print('AB Test Result: $testName, Group: $group, Version: $version, Metrics: $metrics');
  }

  Future<void> incrementTestVersion() async {
    final currentVersion = sharedPreferences.getInt(testVersionKey) ?? 1;
    await sharedPreferences.setInt(testVersionKey, currentVersion + 1);
  }

  Future<Map<String, dynamic>> getTestConfiguration(String userId) async {
    final group = await getTestGroup(userId);
    
    switch (group) {
      case 'A':
        return {
          'useMLRecommendations': false,
          'locationWeight': 0.3,
          'ratingWeight': 0.2,
          'popularityWeight': 0.15,
          'preferenceWeight': 0.35,
        };
      case 'B':
        return {
          'useMLRecommendations': true,
          'locationWeight': 0.25,
          'ratingWeight': 0.15,
          'popularityWeight': 0.15,
          'preferenceWeight': 0.25,
          'mlWeight': 0.2,
        };
      default:
        return {
          'useMLRecommendations': false,
          'locationWeight': 0.3,
          'ratingWeight': 0.2,
          'popularityWeight': 0.15,
          'preferenceWeight': 0.35,
        };
    }
  }
}
