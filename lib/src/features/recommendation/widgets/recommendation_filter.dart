import 'package:flutter/material.dart';

class RecommendationFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const RecommendationFilter({
    Key? key,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<RecommendationFilter> createState() => _RecommendationFilterState();
}

class _RecommendationFilterState extends State<RecommendationFilter> {
  final Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search venues...',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onChanged: (value) {
                  _filters['search'] = value;
                  widget.onFilterChanged(_filters);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        initialFilters: _filters,
        onApply: (filters) {
          setState(() => _filters.addAll(filters));
          widget.onFilterChanged(_filters);
        },
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const FilterDialog({
    Key? key,
    required this.initialFilters,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Options'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Level',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              children: List.generate(4, (index) {
                return ChoiceChip(
                  label: Text(List.filled(index + 1, '₹').join()),
                  selected: _filters['priceLevel'] == index + 1,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters['priceLevel'] = index + 1;
                      } else {
                        _filters.remove('priceLevel');
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'Crowd Level',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Quiet'),
                  selected: _filters['crowdPreference'] == 'quiet',
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters['crowdPreference'] = 'quiet';
                      } else {
                        _filters.remove('crowdPreference');
                      }
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Moderate'),
                  selected: _filters['crowdPreference'] == 'moderate',
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters['crowdPreference'] = 'moderate';
                      } else {
                        _filters.remove('crowdPreference');
                      }
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Busy'),
                  selected: _filters['crowdPreference'] == 'busy',
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters['crowdPreference'] = 'busy';
                      } else {
                        _filters.remove('crowdPreference');
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              children: [
                'Restaurant',
                'Bar',
                'Cafe',
                'Entertainment',
                'Shopping',
                'Culture'
              ].map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: (_filters['categories'] as List<String>?)
                          ?.contains(category) ??
                      false,
                  onSelected: (selected) {
                    setState(() {
                      final categories =
                          (_filters['categories'] as List<String>?) ?? [];
                      if (selected) {
                        _filters['categories'] = [...categories, category];
                      } else {
                        _filters['categories'] = categories
                            .where((item) => item != category)
                            .toList();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Features',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              children: [
                'Outdoor Seating',
                'Wi-Fi',
                'Parking',
                'Live Music',
                'Family Friendly',
                'Pet Friendly'
              ].map((feature) {
                return FilterChip(
                  label: Text(feature),
                  selected:
                      (_filters['features'] as List<String>?)?.contains(feature) ??
                          false,
                  onSelected: (selected) {
                    setState(() {
                      final features =
                          (_filters['features'] as List<String>?) ?? [];
                      if (selected) {
                        _filters['features'] = [...features, feature];
                      } else {
                        _filters['features'] =
                            features.where((item) => item != feature).toList();
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onApply(_filters);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
