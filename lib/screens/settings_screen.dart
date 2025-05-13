import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/offline_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    final offlineManager = Provider.of<OfflineManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Preferences Section
          const Text(
            'App Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                // Theme
                ListTile(
                  title: const Text('Theme'),
                  leading: const Icon(Icons.color_lens),
                  trailing: DropdownButton<ThemeMode>(
                    value: _themeMode,
                    onChanged: (ThemeMode? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _themeMode = newValue;
                        });
                        // In a real app, you would store this preference
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    underline: const SizedBox(),
                  ),
                ),

                // Language
                ListTile(
                  title: const Text('Language'),
                  leading: const Icon(Icons.language),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                        // In a real app, you would update the app's locale
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'Sinhala',
                        child: Text('Sinhala'),
                      ),
                      DropdownMenuItem(
                        value: 'Tamil',
                        child: Text('Tamil'),
                      ),
                    ],
                    underline: const SizedBox(),
                  ),
                ),

                // Currency
                ListTile(
                  title: const Text('Currency'),
                  leading: const Icon(Icons.attach_money),
                  trailing: DropdownButton<String>(
                    value: _selectedCurrency,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCurrency = newValue;
                        });
                        // In a real app, you would store this preference
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD (\$)'),
                      ),
                      DropdownMenuItem(
                        value: 'LKR',
                        child: Text('LKR (Rs)'),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR (€)'),
                      ),
                      DropdownMenuItem(
                        value: 'GBP',
                        child: Text('GBP (£)'),
                      ),
                    ],
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive booking updates and special offers'),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    // In a real app, you would update notification settings
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Notification Preferences'),
                  subtitle: const Text('Customize notification types'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to notification preferences screen
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy Section
          const Text(
            'Privacy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Location Services'),
                  subtitle: const Text('Allow app to access your location'),
                  value: _locationEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _locationEnabled = value;
                    });
                    // In a real app, you would request/revoke location permissions
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show terms of service
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Offline Mode'),
                  subtitle: const Text('Access app features without internet'),
                  value: offlineManager.isOfflineMode,
                  onChanged: (value) {
                    offlineManager.toggleOfflineMode(value);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Clear Cache'),
                  subtitle: Text('Current cache size: 24.5 MB'),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () {
                    // Show clear cache confirmation
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Cache'),
                        content: const Text(
                            'Are you sure you want to clear the app cache? This will not affect your saved data or downloaded regions.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cache cleared successfully'),
                                ),
                              );
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Manage Downloads'),
                  subtitle: Text(
                      'Downloaded regions: ${offlineManager.downloadedRegions.length}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to downloads screen
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('App Version'),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  title: const Text('Check for Updates'),
                  trailing: const Icon(Icons.system_update),
                  onTap: () {
                    // Check for updates
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your app is up to date!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Send Feedback'),
                  trailing: const Icon(Icons.feedback),
                  onTap: () {
                    // Navigate to feedback form
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
