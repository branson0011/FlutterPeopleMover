import 'package:flutter/material.dart';
import '../models/crowd_level_standard.dart';

class CrowdFilterChip extends StatelessWidget {
  final CrowdDensity density;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const CrowdFilterChip({
    Key? key,
    required this.density,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  Color _getChipColor(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getChipColor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(density.toString().split('.').last),
        ],
      ),
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: _getChipColor(context).withOpacity(0.2),
      checkmarkColor: _getChipColor(context),
    );
  }
}
