// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taprobana_trails/presentation/maps/ar_mode_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/utils/permissions.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import 'widgets/settings_option.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PermissionsHandler _permissionsHandler = PermissionsHandler();
  
  bool _isLoading = false;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  String _appVersion = '';
  String _buildNumber = '';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Load user preferences
        _isDarkMode = prefs.getBool('dark_mode') ?? false;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _locationEnabled = prefs.getBool('location_enabled') ?? true;
        _selectedLanguage = prefs.getString('language') ?? 'English';
        _selectedCurrency = prefs.getString('currency') ?? 'USD';
      });
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('Error getting app version: $e');
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save user preferences
      await prefs.setBool('dark_mode', _isDarkMode);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('location_enabled', _locationEnabled);
      await prefs.setString('language', _selectedLanguage);
      await prefs.setString('currency', _selectedCurrency);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error saving settings: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveSettings();
    
    // In a real app, this would trigger a theme change
    // For now, we'll just show a message
    if (_isDarkMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dark mode is not fully implemented yet'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    
    if (value) {
      // Request notification permissions if enabling
      final permissionGranted = await _permissionsHandler.requestNotificationPermission();
      
      if (!permissionGranted) {
        // If permission denied, revert toggle
        setState(() {
          _notificationsEnabled = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission is required to enable notifications'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    
    _saveSettings();
  }

  void _toggleLocation(bool value) async {
    setState(() {
      _locationEnabled = value;
    });
    
    if (value) {
      // Request location permissions if enabling
      final permissionGranted = await _permissionsHandler.requestLocationPermission();
      
      if (!permissionGranted) {
        // If permission denied, revert toggle
        setState(() {
          _locationEnabled = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to enable location services'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    
    _saveSettings();
  }

  void _selectLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildLanguageSelector(),
    );
  }

  void _selectCurrency() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCurrencySelector(),
    );
  }

  Widget _buildLanguageSelector() {
    // Currently supported languages
    final languages = [
      'English',
      'Sinhala',
      'Tamil',
      'Hindi',
      'Chinese',
      'German',
      'French',
      'Japanese',
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                final isSelected = language == _selectedLanguage;
                
                return ListTile(
                  title: Text(language),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    _saveSettings();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    // Popular currencies
    final currencies = [
      {'code': 'USD', 'name': 'US Dollar'},
      {'code': 'EUR', 'name': 'Euro'},
      {'code': 'GBP', 'name': 'British Pound'},
      {'code': 'LKR', 'name': 'Sri Lankan Rupee'},
      {'code': 'INR', 'name': 'Indian Rupee'},
      {'code': 'AUD', 'name': 'Australian Dollar'},
      {'code': 'CAD', 'name': 'Canadian Dollar'},
      {'code': 'JPY', 'name': 'Japanese Yen'},
      {'code': 'CNY', 'name': 'Chinese Yuan'},
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Currency',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = currency['code'] == _selectedCurrency;
                
                return ListTile(
                  title: Text(currency['name']!),
                  subtitle: Text(currency['code']!),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency['code']!;
                    });
                    _saveSettings();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _resetUserPreferences() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Preferences'),
        content: const Text('Are you sure you want to reset all your preferences to default? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              setState(() {
                _isLoading = true;
              });
              
              try {
                final prefs = await SharedPreferences.getInstance();
                
                // Keep only essential preferences like onboarding_completed and logged_in
                final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
                final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
                
                // Clear all preferences
                await prefs.clear();
                
                // Restore essential preferences
                await prefs.setBool('onboarding_completed', onboardingCompleted);
                await prefs.setBool('is_logged_in', isLoggedIn);
                
                // Reset state variables
                setState(() {
                  _isDarkMode = false;
                  _notificationsEnabled = true;
                  _locationEnabled = true;
                  _selectedLanguage = 'English';
                  _selectedCurrency = 'USD';
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferences reset to default'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                // ignore: duplicate_ignore
                // ignore: avoid_print
                print('Error resetting preferences: $e');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error resetting preferences: $e'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Trigger sign out in AuthBloc
              context.read<AuthBloc>().add(SignOutRequested());
              
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              'SIGN OUT',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                    'Please type DELETE to confirm account deletion.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        
                        // Trigger account deletion in AuthBloc
                        context.read<AuthBloc>().add(DeleteAccountRequested());
                        
                        // Navigate to onboarding screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/onboarding',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'DELETE ACCOUNT',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressLoader())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Appearance Section
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  icon: Icons.dark_mode,
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                SettingsOption(
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  icon: Icons.language,
                  onTap: _selectLanguage,
                ),
                SettingsOption(
                  title: 'Currency',
                  subtitle: _selectedCurrency,
                  icon: Icons.currency_exchange,
                  onTap: _selectCurrency,
                ),
                
                const Divider(height: 32),
                
                // Notifications Section
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts and updates',
                  icon: Icons.notifications,
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                
                const Divider(height: 32),
                
                // Privacy Section
                const Text(
                  'Privacy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  title: 'Location Services',
                  subtitle: 'Allow app to access your location',
                  icon: Icons.location_on,
                  trailing: Switch(
                    value: _locationEnabled,
                    onChanged: _toggleLocation,
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                SettingsOption(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Icons.privacy_tip,
                  onTap: () async {
                    final uri = Uri.parse('https://taprobanatrails.com/privacy');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                SettingsOption(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  icon: Icons.description,
                  onTap: () async {
                    final uri = Uri.parse('https://taprobanatrails.com/terms');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                
                const Divider(height: 32),
                
                // Account Section
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  title: 'Reset Preferences',
                  subtitle: 'Restore default settings',
                  icon: Icons.restart_alt,
                  onTap: _resetUserPreferences,
                  iconColor: Colors.orange,
                ),
                SettingsOption(
                  title: 'Sign Out',
                  subtitle: 'Log out of your account',
                  icon: Icons.logout,
                  onTap: _signOut,
                  iconColor: Colors.red,
                ),
                SettingsOption(
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  icon: Icons.delete_forever,
                  onTap: _deleteAccount,
                  iconColor: Colors.red,
                ),
                
                const Divider(height: 32),
                
                // About Section
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  title: 'App Version',
                  subtitle: '$_appVersion (Build $_buildNumber)',
                  icon: Icons.info,
                  onTap: null,
                ),
                SettingsOption(
                  title: 'Rate the App',
                  subtitle: 'Rate us on the App Store',
                  icon: Icons.star,
                  onTap: () async {
                    // Open app store page
                    if (await canLaunchUrl(Uri.parse('market://details?id=com.taprobanatrails.app'))) {
                      await launchUrl(Uri.parse('market://details?id=com.taprobanatrails.app'));
                    } else {
                      await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.taprobanatrails.app'));
                    }
                  },
                ),
                SettingsOption(
                  title: 'Feedback',
                  subtitle: 'Help us improve the app',
                  icon: Icons.feedback,
                  onTap: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'feedback@taprobanatrails.com',
                      query: 'subject=App Feedback - Taprobana Trails&body=',
                    );
                    
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                ),
                SettingsOption(
                  title: 'Visit Our Website',
                  subtitle: 'taprobanatrails.com',
                  icon: Icons.language,
                  onTap: () async {
                    final uri = Uri.parse('https://taprobanatrails.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ],
            ),
    );
  }
}