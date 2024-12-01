class CrowdMetrics {
  final double density;
  final double flowRate;
  final double averageSpeed;
  final double turbulence;
  final DateTime timestamp;

  const CrowdMetrics({
    required this.density,
    required this.flowRate,
    required this.averageSpeed,
    required this.turbulence,
    required this.timestamp,
  });

  factory CrowdMetrics.fromMap(Map<String, dynamic> map) {
    return CrowdMetrics(
      density: map['density']?.toDouble() ?? 0.0,
      flowRate: map['flowRate']?.toDouble() ?? 0.0,
      averageSpeed: map['averageSpeed']?.toDouble() ?? 0.0,
      turbulence: map['turbulence']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'density': density,
      'flowRate': flowRate,
      'averageSpeed': averageSpeed,
      'turbulence': turbulence,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
