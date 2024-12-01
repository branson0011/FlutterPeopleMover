enum CrowdDensity {
  low,       // 0-20% capacity
  moderate,  // 21-40% capacity
  high,      // 41-60% capacity
  veryHigh,  // 61-80% capacity
  critical   // 81-100% capacity
}

class CrowdLevelStandard {
  final CrowdDensity density;
  final double peoplePerSquareMeter;
  final String description;
  final int warningLevel;
  final double capacityPercentage;

  const CrowdLevelStandard({
    required this.density,
    required this.peoplePerSquareMeter,
    required this.description,
    required this.warningLevel,
    required this.capacityPercentage,
  });

  factory CrowdLevelStandard.fromDensity(CrowdDensity density) {
    switch (density) {
      case CrowdDensity.low:
        return const CrowdLevelStandard(
          density: CrowdDensity.low,
          peoplePerSquareMeter: 1.0,
          description: 'Comfortable, uncrowded',
          warningLevel: 0,
          capacityPercentage: 0.2,
        );
      case CrowdDensity.moderate:
        return const CrowdLevelStandard(
          density: CrowdDensity.moderate,
          peoplePerSquareMeter: 2.0,
          description: 'Moderately busy',
          warningLevel: 1,
          capacityPercentage: 0.4,
        );
      case CrowdDensity.high:
        return const CrowdLevelStandard(
          density: CrowdDensity.high,
          peoplePerSquareMeter: 4.0,
          description: 'Busy, some waiting expected',
          warningLevel: 2,
          capacityPercentage: 0.6,
        );
      case CrowdDensity.veryHigh:
        return const CrowdLevelStandard(
          density: CrowdDensity.veryHigh,
          peoplePerSquareMeter: 6.0,
          description: 'Very crowded, significant delays',
          warningLevel: 3,
          capacityPercentage: 0.8,
        );
      case CrowdDensity.critical:
        return const CrowdLevelStandard(
          density: CrowdDensity.critical,
          peoplePerSquareMeter: 8.0,
          description: 'Extremely crowded, potential capacity issues',
          warningLevel: 4,
          capacityPercentage: 1.0,
        );
    }
  }

  static CrowdDensity fromPercentage(double percentage) {
    if (percentage <= 0.2) return CrowdDensity.low;
    if (percentage <= 0.4) return CrowdDensity.moderate;
    if (percentage <= 0.6) return CrowdDensity.high;
    if (percentage <= 0.8) return CrowdDensity.veryHigh;
    return CrowdDensity.critical;
  }
}
