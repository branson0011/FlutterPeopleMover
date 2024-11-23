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
}
