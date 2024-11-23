import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/preference_category.dart';
import '../providers/preference_provider.dart';
import '../providers/recommendation_provider.dart';

class PreferenceOnboardingScreen extends StatefulWidget {
  final String userId;
  final String title;

  const PreferenceOnboardingScreen({
    Key? key,
    required this.userId,
    required this.title,
  }) : super(key: key);

  @override
  State<PreferenceOnboardingScreen> createState() => _PreferenceOnboardingScreenState();
}

class _PreferenceOnboardingScreenState extends State<PreferenceOnboardingScreen> {
  final PageController _pageController = PageController();
  final Map<PreferenceCategory, List<String>> _selectedPreferences = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  void _initializePreferences() {
    for (var category in PreferenceCategory.values) {
      _selectedPreferences[category] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Consumer<PreferenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              _buildPreferenceHeader(),
              _buildPreferenceGroups(),
              _buildRecommendationSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: (_currentPage + 1) / PreferenceCategory.values.length,
    );
  }

  Widget _buildPreferencePages() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        itemCount: PreferenceCategory.values.length,
        itemBuilder: (context, index) {
          final category = PreferenceCategory.values[index];
          return _buildPreferencePage(category);
        },
      ),
    );
  }

  Widget _buildPreferencePage(PreferenceCategory category) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(category),
          const SizedBox(height: 16),
          _buildPreferenceList(category),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(PreferenceCategory category) {
    return Text(
      category.displayName,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildPreferenceList(PreferenceCategory category) {
    return Expanded(
      child: ListView.builder(
        itemCount: category.options.length,
        itemBuilder: (context, index) {
          final option = category.options[index];
          return CheckboxListTile(
            title: Text(option),
            value: _selectedPreferences[category]!.contains(option),
            onChanged: (selected) {
              setState(() {
                if (selected ?? false) {
                  _selectedPreferences[category]!.add(option);
                } else {
                  _selectedPreferences[category]!.remove(option);
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('Previous'),
            ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < PreferenceCategory.values.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _savePreferences();
              }
            },
            child: Text(
              _currentPage < PreferenceCategory.values.length - 1 ? 'Next' : 'Finish',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    final provider = Provider.of<PreferenceProvider>(context, listen: false);
    
    await provider.savePreferences(
      userId: widget.userId,
      preferences: _selectedPreferences,
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Widget _buildRecommendationSection() {
    return Consumer<RecommendationProvider>(
      builder: (context, recommendationProvider, child) {
        if (recommendationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final recommendations = recommendationProvider.recommendations;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Recommended for You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildRecommendationList(recommendations),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationList(List<String> recommendations) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(recommendations[index]),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
