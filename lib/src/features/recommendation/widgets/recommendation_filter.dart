import 'package:flutter/material.dart';

class RecommendationFilter extends StatelessWidget {
  final Map<String, bool> selectedFilters;
  final Function(Map<String, bool>) onFilterChanged;

  const RecommendationFilter({
    Key? key,
    required this.selectedFilters,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip(
              context,
              'Near Me',
              'distance',
              Icons.location_on_outlined,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Top Rated',
              'rating',
              Icons.star_outline,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Popular',
              'popularity',
              Icons.trending_up,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'New',
              'new',
              Icons.fiber_new,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Favorites',
              'favorites',
              Icons.favorite_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String key,
    IconData icon,
  ) {
    final isSelected = selectedFilters[key] ?? false;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        final newFilters = Map<String, bool>.from(selectedFilters);
        newFilters[key] = selected;
        onFilterChanged(newFilters);
      },
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
