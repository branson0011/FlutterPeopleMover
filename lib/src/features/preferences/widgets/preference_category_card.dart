import 'package:flutter/material.dart';
import '../models/preference_category.dart';

class PreferenceCategoryCard extends StatelessWidget {
  final PreferenceCategory category;
  final List<String> selectedOptions;
  final VoidCallback onTap;

  const PreferenceCategoryCard({
    Key? key,
    required this.category,
    required this.selectedOptions,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                selectedOptions.isEmpty
                    ? 'No preferences selected'
                    : selectedOptions.join(', '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
