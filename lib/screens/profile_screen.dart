import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taprobana_trails_app/screens/settings_screen.dart';

import '../services/auth_service.dart';
import '../services/offline_manager.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final offlineManager = Provider.of<OfflineManager>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User not logged in'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to edit profile
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Activity Section
            const Text(
              'Your Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              'My Bookings',
              Icons.confirmation_number,
              Colors.orange,
              () {
                // Navigate to bookings screen
              },
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              context,
              'Saved Places',
              Icons.favorite,
              Colors.red,
              () {
                // Navigate to saved places screen
              },
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              context,
              'Reviews',
              Icons.star,
              Colors.amber,
              () {
                // Navigate to reviews screen
              },
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              context,
              'Trip History',
              Icons.history,
              Colors.blue,
              () {
                // Navigate to trip history screen
              },
            ),
            const SizedBox(height: 24),

            // Offline Content Section
            const Text(
              'Offline Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Offline Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: offlineManager.isOfflineMode,
                          onChanged: (value) {
                            offlineManager.toggleOfflineMode(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Downloaded Regions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    offlineManager.downloadedRegions.isEmpty
                        ? const Text(
                            'No regions downloaded yet',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        : Column(
                            children: offlineManager.downloadedRegions
                                .map((region) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(region),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 20),
                                            onPressed: () {
                                              offlineManager
                                                  .removeDownloadedRegion(
                                                      region);
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show download regions dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Download Region'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                      'Select a region to download for offline use:'),
                                  const SizedBox(height: 16),
                                  ListTile(
                                    title: const Text('Colombo'),
                                    leading: const Icon(Icons.location_city),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Mock download
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Downloading Colombo region...'),
                                        ),
                                      );

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        offlineManager
                                            .downloadRegion('Colombo', []);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Colombo region downloaded successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Kandy'),
                                    leading: const Icon(Icons.landscape),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Mock download
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Downloading Kandy region...'),
                                        ),
                                      );

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        offlineManager
                                            .downloadRegion('Kandy', []);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Kandy region downloaded successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Galle'),
                                    leading: const Icon(Icons.beach_access),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Mock download
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Downloading Galle region...'),
                                        ),
                                      );

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        offlineManager
                                            .downloadRegion('Galle', []);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Galle region downloaded successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download New Region'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Support Section
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              'Help Center',
              Icons.help,
              Colors.purple,
              () {
                // Navigate to help center
              },
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              context,
              'Contact Us',
              Icons.mail,
              Colors.teal,
              () {
                // Navigate to contact us
              },
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              context,
              'About App',
              Icons.info,
              Colors.indigo,
              () {
                // Show about dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'Taprobana Trails',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text(
                      'Taprobana Trails is an all-in-one travel app for Sri Lanka, offering accommodation, dining, and transportation services.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '© 2025 Taprobana Trails. All rights reserved.',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show logout confirmation
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await authService.logout();
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
