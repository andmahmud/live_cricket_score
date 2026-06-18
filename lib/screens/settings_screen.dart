import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/match_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.amber : Colors.orange,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Data & Sync'),
          Consumer<MatchProvider>(
            builder: (context, provider, _) {
              return SwitchListTile(
                title: const Text('Auto Refresh'),
                subtitle: const Text('Automatically refresh scores'),
                secondary: const Icon(Icons.sync),
                value: provider.isAutoRefreshing,
                onChanged: (value) {
                  if (value) {
                    provider.startAutoRefresh();
                  } else {
                    provider.stopAutoRefresh();
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Now'),
            subtitle: const Text('Fetch latest scores'),
            onTap: () {
              context.read<MatchProvider>().refreshFromApi();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cached),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove cached data'),
            onTap: () => _confirmClearCache(context),
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppConstants.appName),
            subtitle: const Text('Version ${AppConstants.appVersion}'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('API'),
            subtitle: const Text('Cricbuzz Unofficial API'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached data. '
          'You will need an internet connection to load data again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
