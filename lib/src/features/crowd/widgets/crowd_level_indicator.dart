import 'package:flutter/material.dart';
import '../models/crowd_level_standard.dart';

class CrowdLevelIndicator extends StatelessWidget {
  final CrowdDensity crowdLevel;
  final bool showLabel;
  final double size;

  const CrowdLevelIndicator({
    Key? key,
    required this.crowdLevel,
    this.showLabel = true,
    this.size = 16.0,
  }) : super(key: key);

  Color _getCrowdLevelColor() {
    switch (crowdLevel) {
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

  String _getCrowdLevelLabel() {
    return crowdLevel.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getCrowdLevelColor(),
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            _getCrowdLevelLabel(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.75,
            ),
          ),
        ],
      ],
    );
  }
}
