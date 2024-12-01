import 'package:flutter/material.dart';
import '../models/crowd_level_standard.dart';
import 'crowd_filter_chip.dart';

class CrowdFilterBar extends StatelessWidget {
  final Set<CrowdDensity> selectedDensities;
  final ValueChanged<Set<CrowdDensity>> onSelectionChanged;

  const CrowdFilterBar({
    Key? key,
    required this.selectedDensities,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: CrowdDensity.values.map((density) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CrowdFilterChip(
                density: density,
                isSelected: selectedDensities.contains(density),
                onSelected: (selected) {
                  final newSelection = Set<CrowdDensity>.from(selectedDensities);
                  if (selected) {
                    newSelection.add(density);
                  } else {
                    newSelection.remove(density);
                  }
                  onSelectionChanged(newSelection);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
