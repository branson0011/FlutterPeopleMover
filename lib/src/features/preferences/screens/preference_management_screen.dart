import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preference_provider.dart';
import '../models/user_preferences.dart';

class PreferenceManagementScreen extends StatelessWidget {
  const PreferenceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: Consumer<PreferenceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final preferences = provider.preferences;
          if (preferences == null) {
            return const Center(child: Text('No preferences found'));
          }

          return ListView(
            children: [
              _buildPreferenceSection(
                context,
                'Communication',
                preferences.preferences['communication'] ?? [],
                (value) => provider.updatePreference(
                  preferences.userId,
                  'communication',
                  value,
                ),
              ),
              _buildPreferenceSection(
                context,
                'Privacy',
                preferences.preferences['privacy'] ?? [],
                (value) => provider.updatePreference(
                  preferences.userId,
                  'privacy',
                  value,
                ),
              ),
              _buildPreferenceSection(
                context,
                'Interests',
                preferences.preferences['interests'] ?? [],
                (value) => provider.updatePreference(
                  preferences.userId,
                  'interests',
                  value,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreferenceSection(
    BuildContext context,
    String title,
    List<dynamic> values,
    Function(List<String>) onUpdate,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(title),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(values[index].toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final updatedValues = List<String>.from(values)
                      ..removeAt(index);
                    onUpdate(updatedValues);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
