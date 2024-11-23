import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Account',
            [
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile Settings',
                onTap: () => Navigator.pushNamed(context, '/profile/settings'),
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => Navigator.pushNamed(context, '/settings/notifications'),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
              ),
            ],
          ),
          _buildSection(
            context,
            'Preferences',
            [
              SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                onTap: () => Navigator.pushNamed(context, '/settings/language'),
              ),
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                onTap: () => Navigator.pushNamed(context, '/settings/theme'),
              ),
              SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Location Services',
                onTap: () => Navigator.pushNamed(context, '/settings/location'),
              ),
            ],
          ),
          _buildSection(
            context,
            'Data & Storage',
            [
              SettingsTile(
                icon: Icons.storage_outlined,
                title: 'Storage Usage',
                onTap: () => Navigator.pushNamed(context, '/settings/storage'),
              ),
              SettingsTile(
                icon: Icons.cached_outlined,
                title: 'Clear Cache',
                onTap: () => _showClearCacheDialog(context),
              ),
            ],
          ),
          _buildSection(
            context,
            'Support',
            [
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () => Navigator.pushNamed(context, '/settings/help'),
              ),
              SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Problem',
                onTap: () => Navigator.pushNamed(context, '/settings/report'),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () => Navigator.pushNamed(context, '/settings/about'),
              ),
            ],
          ),
          _buildSection(
            context,
            'Account Actions',
            [
              SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                onTap: () => _showSignOutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...tiles,
        const Divider(),
      ],
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Implement cache clearing logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive 
        ? Theme.of(context).colorScheme.error
        : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
