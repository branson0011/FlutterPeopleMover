import 'package:flutter/material.dart';

enum CrowdLevel {
  veryEmpty(1, 'Very Empty', 'Almost no people here', '#4CAF50'),    // Green
  light(2, 'Light', 'Comfortably uncrowded', '#8BC34A'),            // Light Green
  moderate(3, 'Moderate', 'Average crowd level', '#FFC107'),         // Amber
  busy(4, 'Busy', 'Getting crowded', '#FF9800'),                     // Orange
  veryCrowded(5, 'Very Crowded', 'Extremely busy', '#F44336');      // Red

  final int level;
  final String label;
  final String description;
  final String colorCode;

  const CrowdLevel(this.level, this.label, this.description, this.colorCode);

  static CrowdLevel fromLevel(int level) {
    return CrowdLevel.values.firstWhere(
      (e) => e.level == level,
      orElse: () => CrowdLevel.moderate,
    );
  }

  Color get color => Color(int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000);

  IconData get icon {
    switch (this) {
      case CrowdLevel.veryEmpty:
        return Icons.person_outline;
      case CrowdLevel.light:
        return Icons.people_outline;
      case CrowdLevel.moderate:
        return Icons.groups_outlined;
      case CrowdLevel.busy:
        return Icons.groups;
      case CrowdLevel.veryCrowded:
        return Icons.groups_2;
    }
  }
}

class CrowdLevelData {
  final CrowdLevel level;
  final double confidence;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic>? metadata;

  CrowdLevelData({
    required this.level,
    required this.confidence,
    required this.timestamp,
    required this.source,
    this.metadata,
  });

  factory CrowdLevelData.fromMap(Map<String, dynamic> map) {
    return CrowdLevelData(
      level: CrowdLevel.fromLevel(map['level'] as int),
      confidence: map['confidence'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      source: map['source'] as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level.level,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'metadata': metadata,
    };
  }
}
