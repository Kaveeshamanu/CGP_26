import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/offline_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Attractions', 'Hotels', 'Restaurants', 'Transport'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final offlineManager = Provider.of<OfflineManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: Icon(
              offlineManager.isOfflineMode
                  ? Icons.wifi_off
                  : Icons.wifi,
            ),
            onPressed: () {
              offlineManager.toggleOfflineMode(!offlineManager.isOfflineMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search places...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: _isSearchFocused
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearchFocused = false;
                          });
                          FocusScope.of(context).unfocus();
                        },
                      )
                          : null,
                    ),
                    onTap: () {
                      setState(() {
                        _isSearchFocused = true;
                      });
                    },
                    onSubmitted: (_) {
                      setState(() {
                        _isSearchFocused = false;
                      });
                    },
                  ),
                ),
                if (_isSearchFocused) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearchFocused = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Map View
          Expanded(
            child: Stack(
              children: [
                // Here you would integrate a map like Google Maps
                // For now, we'll use a placeholder
                Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: offlineManager.isOfflineMode
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Offline Map',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Using downloaded map data',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Interactive Map',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'In a real app, this would be a Google Map or similar',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Action Buttons
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'ar-mode',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AR Mode activated!'),
                            ),
                          );
                        },
                        backgroundColor: Colors.amber,
                        child: const Icon(Icons.view_in_ar),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'my-location',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Locating you...'),
                            ),
                          );
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),

                // Download Map Button (when online)
                if (!offlineManager.isOfflineMode)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Download Map'),
                            content: const Text(
                              'Do you want to download this area for offline use?',
                            ),
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
                                      content: Text('Map downloaded for offline use'),
                                    ),
                                  );
                                },
                                child: const Text('Download'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
