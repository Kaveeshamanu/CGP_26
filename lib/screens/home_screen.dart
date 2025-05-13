import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:taprobana_trails_app/screens/profile_screen.dart';
import 'package:taprobana_trails_app/screens/transportation_screen.dart';

import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/offline_manager.dart';
import '../widgets/place_card.dart';
import 'accommodation_screen.dart';
import 'dining_screen.dart';
import 'itinerary_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeContent(),
    const MapScreen(),
    const ItineraryScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );

  }

}
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    // Fetch nearby places
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService = Provider.of<LocationService>(
          context, listen: false);
      locationService.fetchNearbyPlaces(6.9271, 79.8612); // Colombo coordinates
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final locationService = Provider.of<LocationService>(context);
    final offlineManager = Provider.of<OfflineManager>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Taprobana Trails'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://www.srilankatravelandtourism.com/wp-content/uploads/2020/04/sigiriya-rock-fortress-sri-lanka.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  offlineManager.isOfflineMode
                      ? Icons.wifi_off
                      : Icons.wifi,
                ),
                onPressed: () {
                  offlineManager.toggleOfflineMode(
                      !offlineManager.isOfflineMode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        offlineManager.isOfflineMode
                            ? 'Offline mode enabled'
                            : 'Online mode enabled',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Welcome Message
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${authService.currentUser?.name ?? 'Traveler'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.home),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover the beauty of Sri Lanka with our comprehensive travel guide.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Services Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildServiceCard(
                        context,
                        'Accommodation',
                        Icons.hotel,
                        Colors.blue,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccommodationScreen(),
                            ),
                          );
                        },
                      ),
                      _buildServiceCard(
                        context,
                        'Dining',
                        Icons.restaurant,
                        Colors.orange,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DiningScreen(),
                            ),
                          );
                        },
                      ),
                      _buildServiceCard(
                        context,
                        'Transportation',
                        Icons.directions_car,
                        Colors.green,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (
                                  context) => const TransportationScreen(),
                            ),
                          );
                        },
                      ),
                      _buildServiceCard(
                        context,
                        'Itinerary',
                        Icons.calendar_today,
                        Colors.purple,
                            () {
                          setState(() {
                            (context.findAncestorStateOfType<
                                _HomeScreenState>())
                                ?._currentIndex = 2;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (
                                  context) => const ItineraryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Popular Destinations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Destinations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (locationService.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    if (locationService.places.isEmpty)
                      const Center(
                        child: Text(
                          'No destinations available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: locationService.places
                            .map(
                              (place) =>
                              PlaceCard(
                                place, () {
                                // Navigate to place details screen
                              },
                              ),
                        )
                            .toList(),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}