import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/user_preference.dart';

class PreferenceSettingsScreen extends StatefulWidget {
  final String userId;

  const PreferenceSettingsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<PreferenceSettingsScreen> createState() => _PreferenceSettingsScreenState();
}

class _PreferenceSettingsScreenState extends State<PreferenceSettingsScreen> {
  final Map<String, double> _categoryWeights = {};
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<RecommendationProvider>(context, listen: false);
      final preferences = await provider.getUserPreferences(widget.userId);
      
      setState(() {
        _categoryWeights.addAll(preferences.categoryWeights);
        _selectedCategories.addAll(
          preferences.explicitPreferences['categories'] ?? [],
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategorySection(),
                const Divider(height: 32),
                _buildPreferenceSliders(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _savePreferences,
                  child: const Text('Save Preferences'),
                ),
              ],
            ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Restaurants',
            'Cafes',
            'Bars',
            'Shopping',
            'Entertainment',
            'Sports',
            'Culture',
            'Outdoors',
          ].map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferenceSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildPreferenceSlider(
          'Distance',
          'Prefer places closer to me',
          _categoryWeights['distance'] ?? 0.5,
          (value) {
            setState(() => _categoryWeights['distance'] = value);
          },
        ),
        _buildPreferenceSlider(
          'Rating',
          'Prefer highly rated places',
          _categoryWeights['rating'] ?? 0.5,
          (value) {
            setState(() => _categoryWeights['rating'] = value);
          },
        ),
        _buildPreferenceSlider(
          'Popularity',
          'Prefer popular places',
          _categoryWeights['popularity'] ?? 0.5,
          (value) {
            setState(() => _categoryWeights['popularity'] = value);
          },
        ),
        _buildPreferenceSlider(
          'Price',
          'Prefer budget-friendly places',
          _categoryWeights['price'] ?? 0.5,
          (value) {
            setState(() => _categoryWeights['price'] = value);
          },
        ),
      ],
    );
  }

  Widget _buildPreferenceSlider(
    String title,
    String subtitle,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          divisions: 10,
          label: value.toString(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<RecommendationProvider>(context, listen: false);
      await provider.updatePreferences(
        userId: widget.userId,
        preferences: UserPreference(
          userId: widget.userId,
          categoryWeights: _categoryWeights,
          explicitPreferences: {
            'categories': _selectedCategories,
          },
          implicitPreferences: {},
          lastUpdated: DateTime.now(),
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
