class CacheMetrics {
  final Map<String, int> _hits = {};
  final Map<String, int> _misses = {};
  final Map<String, int> _evictions = {};
  final Stopwatch _timer = Stopwatch()..start();

  void recordHit(String key) {
    _hits[key] = (_hits[key] ?? 0) + 1;
  }

  void recordMiss(String key) {
    _misses[key] = (_misses[key] ?? 0) + 1;
  }

  void recordEviction(String key) {
    _evictions[key] = (_evictions[key] ?? 0) + 1;
  }

  Map<String, double> getHitRatios() {
    final ratios = <String, double>{};
    final keys = {..._hits.keys, ..._misses.keys};
    
    for (final key in keys) {
      final hits = _hits[key] ?? 0;
      final misses = _misses[key] ?? 0;
      final total = hits + misses;
      ratios[key] = total > 0 ? hits / total : 0.0;
    }
    
    return ratios;
  }

  Map<String, int> getEvictionCounts() {
    return Map.from(_evictions);
  }

  Duration getUptime() {
    return _timer.elapsed;
  }

  void reset() {
    _hits.clear();
    _misses.clear();
    _evictions.clear();
    _timer.reset();
    _timer.start();
  }

  Map<String, dynamic> getMetrics() {
    return {
      'hit_ratios': getHitRatios(),
      'evictions': getEvictionCounts(),
      'uptime': getUptime().inSeconds,
    };
  }
}
