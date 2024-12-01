import 'package:flutter/material.dart';
import '../models/crowd_level_standard.dart';

class CrowdLevelBadge extends StatelessWidget {
  final CrowdDensity density;
  final double size;
  final bool showLabel;
  final bool animate;

  const CrowdLevelBadge({
    Key? key,
    required this.density,
    this.size = 24.0,
    this.showLabel = true,
    this.animate = false,
  }) : super(key: key);

  Color _getDensityColor() {
    switch (density) {
      case CrowdDensity.low:
        return Colors.green;
      case CrowdDensity.moderate:
        return Colors.yellow;
      case CrowdDensity.high:
        return Colors.orange;
      case CrowdDensity.veryHigh:
        return Colors.deepOrange;
      case CrowdDensity.critical:
        return Colors.red;
    }
  }

  String _getDensityLabel() {
    switch (density) {
      case CrowdDensity.low:
        return 'Not Crowded';
      case CrowdDensity.moderate:
        return 'Moderate';
      case CrowdDensity.high:
        return 'Busy';
      case CrowdDensity.veryHigh:
        return 'Very Busy';
      case CrowdDensity.critical:
        return 'Extremely Busy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDensityColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getDensityColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size / 2,
            height: size / 2,
            decoration: BoxDecoration(
              color: _getDensityColor(),
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getDensityLabel(),
              style: TextStyle(
                color: _getDensityColor(),
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
