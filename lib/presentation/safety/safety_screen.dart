import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taprobana_trails/presentation/maps/ar_mode_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/location/location_service.dart';
import '../../core/utils/permissions.dart';
import '../../data/models/destination.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/buttons.dart';
import 'widgets/sos_button.dart';
import 'widgets/alert_card.dart';
import 'emergency_screen.dart';

class SafetyScreen extends StatefulWidget {
  final String? destinationId;

  const SafetyScreen({
    super.key,
    this.destinationId,
  });

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final LocationService _locationService = LocationService();
  final PermissionsHandler _permissionsHandler = PermissionsHandler();

  bool _isLoading = false;
  Position? _currentPosition;
  Destination? _destination;
  bool _locationPermissionGranted = false;

  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      type: 'Police',
      number: '119',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyContact(
      type: 'Ambulance',
      number: '110',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    EmergencyContact(
      type: 'Fire',
      number: '111',
      icon: Icons.fire_truck,
      color: Colors.orange,
    ),
    EmergencyContact(
      type: 'Tourist Police',
      number: '1912',
      icon: Icons.badge,
      color: Colors.green,
    ),
    EmergencyContact(
      type: 'Emergency',
      number: '112',
      icon: Icons.emergency,
      color: Colors.purple,
    ),
  ];

  final List<SafetyTip> _safetyTips = [
    SafetyTip(
      title: 'Keep your documents safe',
      description:
          'Always keep a digital copy of your passport and travel documents. Store physical copies in your hotel safe.',
      icon: Icons.assignment,
    ),
    SafetyTip(
      title: 'Stay hydrated',
      description:
          'Sri Lanka can be hot and humid. Drink bottled water and carry water with you, especially when sightseeing.',
      icon: Icons.water_drop,
    ),
    SafetyTip(
      title: 'Respect wildlife',
      description:
          'Keep a safe distance from wild animals. Never feed or provoke them, especially elephants and monkeys.',
      icon: Icons.pets,
    ),
    SafetyTip(
      title: 'Be cautious of scams',
      description:
          'Be wary of strangers offering unsolicited help or unusual deals. Use official taxis and tour operators.',
      icon: Icons.warning,
    ),
    SafetyTip(
      title: 'Dress appropriately',
      description:
          'When visiting temples or religious sites, dress modestly covering shoulders and knees out of respect.',
      icon: Icons.accessibility,
    ),
  ];

  final List<SafetyAlert> _currentAlerts = [
    SafetyAlert(
      title: 'Heavy rain in Central Province',
      description:
          'Heavy rain expected in Kandy, Nuwara Eliya, and surrounding areas. Flash floods possible in low-lying areas.',
      severity: AlertSeverity.moderate,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SafetyAlert(
      title: 'Road closure on A9 Highway',
      description:
          'Temporary road closure on A9 Highway between Kandy and Jaffna due to maintenance work. Expect delays.',
      severity: AlertSeverity.low,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getCurrentLocation();

    // Load destination data if destinationId is provided
    if (widget.destinationId != null) {
      context.read<DestinationBloc>().add(
            LoadDestinationDetails(destinationId: widget.destinationId!),
          );
    }
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await _permissionsHandler.checkLocationPermission();
    setState(() {
      _locationPermissionGranted = hasPermission;
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting current position: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToEmergencyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyScreen(),
      ),
    );
  }

  Future<void> _callEmergencyNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not call $number'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareCurrentLocation() {
    if (_currentPosition != null) {
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;

      final locationUrl = 'https://maps.google.com/?q=$lat,$lng';

      Share.share(
        'My current location: $locationUrl\n\nSent via Taprobana Trails safety feature.',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Unable to share location. Please enable location services.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSosOptionsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Emergency Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.red),
              ),
              title: const Text('Call Emergency Services'),
              subtitle: const Text('Contact local emergency number'),
              onTap: () {
                Navigator.pop(context);
                _callEmergencyNumber('112');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_location, color: Colors.blue),
              ),
              title: const Text('Share My Location'),
              subtitle: const Text('Send your current location to contacts'),
              onTap: () {
                Navigator.pop(context);
                _shareCurrentLocation();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Colors.orange),
              ),
              title: const Text('View Emergency Information'),
              subtitle: const Text('See all emergency contacts'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEmergencyScreen();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Travel Safety',
        showBackButton: true,
      ),
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationsLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is DestinationsError) {
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is DestinationDetailsLoaded &&
              state.destination.id == widget.destinationId) {
            setState(() {
              _destination = state.destination;
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildSafetyContent(),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: SOSButton(
        onPressed: _showSosOptionsModal,
      ),
    );
  }

  Widget _buildSafetyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOS Card
          _buildSosCard(),

          const SizedBox(height: 24),

          // Current alerts section
          if (_currentAlerts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to alerts history
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._currentAlerts.map((alert) => AlertCard(
                  alert: alert,
                  onTap: () {
                    // Show alert details
                  },
                )),
            const SizedBox(height: 16),
          ],

          // Emergency contacts section
          const Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEmergencyContactsGrid(),
          const SizedBox(height: 24),

          // Safety tips section
          const Text(
            'Safety Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._safetyTips.map(_buildSafetyTipCard),

          const SizedBox(height: 24),

          // Embassy information section
          if (_destination != null) ...[
            const Text(
              'Embassy Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmbassyCard(),
          ],

          // Extra space at bottom for floating action button
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSosCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Get immediate assistance when needed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergencyNumber('112'),
                    icon: const Icon(Icons.call),
                    label: const Text('Call Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareCurrentLocation,
                    icon: const Icon(Icons.share_location),
                    label: const Text('Share Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _emergencyContacts.length,
      itemBuilder: (context, index) {
        final contact = _emergencyContacts[index];
        return _buildEmergencyContactCard(contact);
      },
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact) {
    return InkWell(
      onTap: () => _callEmergencyNumber(contact.number),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: contact.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                contact.icon,
                color: contact.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contact.type,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              contact.number,
              style: TextStyle(
                color: contact.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTipCard(SafetyTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tip.icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbassyCard() {
    // This would normally come from destination data
    // Using placeholder content for now
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'US Embassy in Colombo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '210 Galle Road, Colombo 3, Sri Lanka',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Phone: +94 11 249 8500',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Emergency: +94 11 249 8888',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callEmergencyNumber('+94 11 249 8500'),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('https://lk.usembassy.gov/');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.language),
                    label: const Text('Website'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

CircularProgressLoader() {}

class EmergencyContact {
  final String type;
  final String number;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.type,
    required this.number,
    required this.icon,
    required this.color,
  });
}

class SafetyTip {
  final String title;
  final String description;
  final IconData icon;

  SafetyTip({
    required this.title,
    required this.description,
    required this.icon,
  });
}

enum AlertSeverity {
  low,
  moderate,
  high,
}

class SafetyAlert {
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime date;

  SafetyAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.date,
  });
}
