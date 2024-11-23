import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/preference_provider.dart'; // Adjust the import according to your project structure

class PreferenceDetailScreen extends StatefulWidget {
  final String title;

  const PreferenceDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  _PreferenceDetailScreenState createState() => _PreferenceDetailScreenState();
}

class _PreferenceDetailScreenState extends State<PreferenceDetailScreen> {
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

  Widget _buildPreferenceHeader() {
    // Implementation for the preference header
  }

  Widget _buildPreferenceGroups() {
    // Implementation for the preference groups
  }

  Widget _buildRecommendationSection() {
    // Implementation for the recommendation section
  }
}
