import 'package:flutter/material.dart';
import '../models/crowd_level.dart';

class CrowdLevelFilter extends StatelessWidget {
  final List<CrowdLevel> selectedLevels;
  final ValueChanged<List<CrowdLevel>> onChanged;

  const CrowdLevelFilter({
    Key? key,
    required this.selectedLevels,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crowd Level',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CrowdLevel.values.map((level) {
            final isSelected = selectedLevels.contains(level);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    level.getIcon(),
                    size: 16,
                    color: isSelected ? Colors.white : level.getColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(level.label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<CrowdLevel>.from(selectedLevels);
                if (selected) {
                  newSelection.add(level);
                } else {
                  newSelection.remove(level);
                }
                onChanged(newSelection);
              },
              selectedColor: level.getColor(),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}
