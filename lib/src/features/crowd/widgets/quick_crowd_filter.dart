import 'package:flutter/material.dart';
import '../models/crowd_level_standard.dart';

class QuickCrowdFilter extends StatelessWidget {
  final CrowdDensity? selectedDensity;
  final ValueChanged<CrowdDensity?> onFilterChanged;

  const QuickCrowdFilter({
    Key? key,
    this.selectedDensity,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Quick Filter',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: [
                _buildFilterChip(
                  context,
                  'Less Crowded',
                  CrowdDensity.low,
                ),
                _buildFilterChip(
                  context,
                  'Moderate',
                  CrowdDensity.moderate,
                ),
                _buildFilterChip(
                  context,
                  'Any',
                  null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    CrowdDensity? density,
  ) {
    final isSelected = selectedDensity == density;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onFilterChanged(density),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
