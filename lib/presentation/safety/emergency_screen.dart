// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../core/location/location_service.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final LocationService _locationService = LocationService();
  
  bool _isLoading = false;
  Position? _currentPosition;
  
  // Embassy contact information
  final List<Embassy> _embassies = [
    Embassy(
      country: 'United States',
      address: '210 Galle Road, Colombo 3, Sri Lanka',
      phone: '+94 11 249 8500',
      emergencyPhone: '+94 11 249 8888',
      website: 'https://lk.usembassy.gov/',
      flagCode: 'us',
    ),
    Embassy(
      country: 'United Kingdom',
      address: '389 Bauddhaloka Mawatha, Colombo 7, Sri Lanka',
      phone: '+94 11 539 0639',
      emergencyPhone: '+94 11 539 0999',
      website: 'https://www.gov.uk/world/organisations/british-high-commission-colombo',
      flagCode: 'gb',
    ),
    Embassy(
      country: 'Australia',
      address: '21 R.A. De Mel Mawatha, Colombo 4, Sri Lanka',
      phone: '+94 11 246 3200',
      emergencyPhone: '+94 11 246 3333',
      website: 'https://srilanka.embassy.gov.au/',
      flagCode: 'au',
    ),
    Embassy(
      country: 'Canada',
      address: '33A 5th Lane, Colombo 3, Sri Lanka',
      phone: '+94 11 522 6232',
      emergencyPhone: '+94 11 522 6400',
      website: 'https://www.canadainternational.gc.ca/sri_lanka/',
      flagCode: 'ca',
    ),
    Embassy(
      country: 'India',
      address: '36-38, Galle Road, Colombo 3, Sri Lanka',
      phone: '+94 11 232 6833',
      emergencyPhone: '+94 11 242 2788',
      website: 'https://hcicolombo.gov.in/',
      flagCode: 'in',
    ),
  ];
  
  // Emergency service information
  final List<EmergencyService> _emergencyServices = [
    EmergencyService(
      name: 'Police Emergency',
      number: '119',
      description: 'For police assistance and emergencies',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyService(
      name: 'Ambulance Service',
      number: '110',
      description: 'For medical emergencies requiring ambulance',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    EmergencyService(
      name: 'Fire Department',
      number: '111',
      description: 'For fire emergencies and rescue services',
      icon: Icons.fire_truck,
      color: Colors.orange,
    ),
    EmergencyService(
      name: 'Tourist Police',
      number: '1912',
      description: 'Specialized police service for tourists',
      icon: Icons.badge,
      color: Colors.green,
    ),
    EmergencyService(
      name: 'Disaster Management',
      number: '117',
      description: 'For natural disasters and related emergencies',
      icon: Icons.warning_amber,
      color: Colors.amber,
    ),
    EmergencyService(
      name: 'Government Information',
      number: '1919',
      description: 'For general government information',
      icon: Icons.info,
      color: Colors.teal,
    ),
  ];
  
  // Hospital information
  final List<Hospital> _hospitals = [
    Hospital(
      name: 'National Hospital of Sri Lanka',
      address: 'Regent Street, Colombo 10',
      phone: '+94 11 269 1111',
      isOpen24Hours: true,
      latitude: 6.9253,
      longitude: 79.8641,
    ),
    Hospital(
      name: 'Lanka Hospitals',
      address: '578 Elvitigala Mawatha, Colombo 5',
      phone: '+94 11 543 0000',
      isOpen24Hours: true,
      latitude: 6.9087,
      longitude: 79.8675,
    ),
    Hospital(
      name: 'Nawaloka Hospital',
      address: '23 Deshamanya H.K Dharmadasa Mawatha, Colombo 2',
      phone: '+94 11 557 7111',
      isOpen24Hours: true,
      latitude: 6.9346,
      longitude: 79.8504,
    ),
    Hospital(
      name: 'Asiri Central Hospital',
      address: '114 Norris Canal Road, Colombo 10',
      phone: '+94 11 466 5500',
      isOpen24Hours: true,
      latitude: 6.9294,
      longitude: 79.8612,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
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

  Future<void> _openMap(double latitude, double longitude, String label) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$label');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps'),
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
          content: Text('Unable to share location. Please enable location services.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Information'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Emergency'),
              Tab(text: 'Hospitals'),
              Tab(text: 'Embassies'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildEmergencyServicesList(),
                _buildHospitalsList(),
                _buildEmbassiesList(),
              ],
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressLoader(),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callNumber('112'),
                    icon: const Icon(Icons.call),
                    label: const Text('Emergency Call'),
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyServicesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emergencyServices.length,
      itemBuilder: (context, index) {
        final service = _emergencyServices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                service.icon,
                color: service.color,
                size: 24,
              ),
            ),
            title: Text(
              service.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: service.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.number,
                        style: TextStyle(
                          color: service.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              color: service.color,
              onPressed: () => _callNumber(service.number),
            ),
            onTap: () => _callNumber(service.number),
          ),
        );
      },
    );
  }

  Widget _buildHospitalsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hospitals.length,
      itemBuilder: (context, index) {
        final hospital = _hospitals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hospital.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (hospital.isOpen24Hours)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Open 24 Hours',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
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
                      child: OutlinedButton.icon(
                        onPressed: () => _callNumber(hospital.phone),
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openMap(
                          hospital.latitude,
                          hospital.longitude,
                          hospital.name,
                        ),
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmbassiesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _embassies.length,
      itemBuilder: (context, index) {
        final embassy = _embassies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Center(
                child: Text(
                  embassy.country.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              '${embassy.country} Embassy',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              embassy.phone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            embassy.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 16),
                          onPressed: () => _copyToClipboard(embassy.address),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.call_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            embassy.phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, size: 16),
                          onPressed: () => _callNumber(embassy.phone),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.emergency_outlined,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Emergency: ${embassy.emergencyPhone}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, size: 16, color: Colors.red),
                          onPressed: () => _callNumber(embassy.emergencyPhone),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(embassy.website);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.language),
                      label: const Text('Visit Website'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmergencyService {
  final String name;
  final String number;
  final String description;
  final IconData icon;
  final Color color;

  EmergencyService({
    required this.name,
    required this.number,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class Hospital {
  final String name;
  final String address;
  final String phone;
  final bool isOpen24Hours;
  final double latitude;
  final double longitude;

  Hospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.isOpen24Hours,
    required this.latitude,
    required this.longitude,
  });
}

class Embassy {
  final String country;
  final String address;
  final String phone;
  final String emergencyPhone;
  final String website;
  final String flagCode;

  Embassy({
    required this.country,
    required this.address,
    required this.phone,
    required this.emergencyPhone,
    required this.website,
    required this.flagCode,
  });
}