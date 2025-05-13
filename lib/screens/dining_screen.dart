import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class DiningScreen extends StatefulWidget {
  const DiningScreen({super.key});

  @override
  State<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends State<DiningScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCuisine = 'All';
  final List<String> _cuisines = [
    'All',
    'Sri Lankan',
    'Indian',
    'Chinese',
    'Italian',
    'Seafood',
    'Vegetarian'
  ];

  // Mock data for restaurants
  final List<Restaurant> _restaurants = [
    Restaurant(
      id: 'rest-1',
      name: 'Ministry of Crab',
      cuisine: 'Seafood',
      rating: 4.8,
      priceRange: '\$\$\$',
      imageUrl: 'https://ministryofcrab.com/colombo/wp-content/uploads/2022/09/MoC_Interior.png',
      address: 'Old Dutch Hospital, Colombo 01',
      description: 'Renowned seafood restaurant specializing in Sri Lankan crab dishes.',
      openingHours: {
        'Mon': '12:00 PM - 10:00 PM',
        'Tue': '12:00 PM - 10:00 PM',
        'Wed': '12:00 PM - 10:00 PM',
        'Thu': '12:00 PM - 10:00 PM',
        'Fri': '12:00 PM - 10:00 PM',
        'Sat': '12:00 PM - 10:00 PM',
        'Sun': '12:00 PM - 10:00 PM',
      },
    ),
    Restaurant(
      id: 'rest-2',
      name: 'Upali\'s by Nawaloka',
      cuisine: 'Sri Lankan',
      rating: 4.5,
      priceRange: '\$\$',
      imageUrl: 'https://media-cdn.tripadvisor.com/media/photo-s/11/a9/2c/5d/upali-s-by-nawaloka.jpg',
      address: '65 Dr C.W.W. Kannangara Mawatha, Colombo',
      description: 'Authentic Sri Lankan cuisine in a modern setting.',
      openingHours: {
        'Mon': '7:00 AM - 10:30 PM',
        'Tue': '7:00 AM - 10:30 PM',
        'Wed': '7:00 AM - 10:30 PM',
        'Thu': '7:00 AM - 10:30 PM',
        'Fri': '7:00 AM - 10:30 PM',
        'Sat': '7:00 AM - 10:30 PM',
        'Sun': '7:00 AM - 10:30 PM',
      },
    ),
    Restaurant(
      id: 'rest-3',
      name: 'Nihonbashi',
      cuisine: 'Japanese',
      rating: 4.7,
      priceRange: '\$\$\$',
      imageUrl: 'https://media-cdn.tripadvisor.com/media/photo-s/15/01/9a/58/restaurant-entrance.jpg',
      address: '11 Galle Face Terrace, Colombo 03',
      description: 'Premium Japanese cuisine with fresh seafood.',
      openingHours: {
        'Mon': '12:00 PM - 2:30 PM, 6:30 PM - 10:30 PM',
        'Tue': '12:00 PM - 2:30 PM, 6:30 PM - 10:30 PM',
        'Wed': '12:00 PM - 2:30 PM, 6:30 PM - 10:30 PM',
        'Thu': '12:00 PM - 2:30 PM, 6:30 PM - 10:30 PM',
        'Fri': '12:00 PM - 2:30 PM, 6:30 PM - 10:30 PM',
        'Sat': '12:00 PM - 2:30 PM, 6:30 PM - 10:30 PM',
        'Sun': 'Closed',
      },
    ),
    Restaurant(
      id: 'rest-4',
      name: 'Kaema Sutra',
      cuisine: 'Sri Lankan',
      rating: 4.6,
      priceRange: '\$\$\$',
      imageUrl: 'https://media-cdn.tripadvisor.com/media/photo-s/12/48/d5/bf/our-new-home-at-shangri.jpg',
      address: 'Shangri-La Hotel, Colombo',
      description: 'Contemporary Sri Lankan cuisine with a modern twist.',
      openingHours: {
        'Mon': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
        'Tue': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
        'Wed': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
        'Thu': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
        'Fri': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
        'Sat': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
        'Sun': '12:00 PM - 3:00 PM, 7:00 PM - 11:00 PM',
      },
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> get _filteredRestaurants {
    return _restaurants.where((restaurant) {
      // Apply cuisine filter
      if (_selectedCuisine != 'All' && restaurant.cuisine != _selectedCuisine) {
        return false;
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return restaurant.name.toLowerCase().contains(searchTerm) ||
            restaurant.cuisine.toLowerCase().contains(searchTerm) ||
            restaurant.description.toLowerCase().contains(searchTerm);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dining'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Cuisine Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: _cuisines.map((cuisine) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cuisine),
                    selected: _selectedCuisine == cuisine,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCuisine = cuisine;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Restaurant List
          Expanded(
            child: _filteredRestaurants.isEmpty
                ? const Center(
              child: Text(
                'No restaurants found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailScreen(
                            restaurant: restaurant,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            restaurant.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            },
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cuisine and Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Cuisine
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      restaurant.cuisine,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Rating
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        restaurant.rating.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Name
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Price Range
                              Text(
                                restaurant.priceRange,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Address
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      restaurant.address,
                                      style: TextStyle(
                                        color: Colors.grey[700],
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show reservation dialog
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const ReservationBottomSheet(),
          );
        },
        icon: const Icon(Icons.restaurant),
        label: const Text('Make a Reservation'),
      ),
    );
  }
}
class ReservationBottomSheet extends StatefulWidget {
  const ReservationBottomSheet({super.key});

  @override
  _ReservationBottomSheetState createState() => _ReservationBottomSheetState();
}

class _ReservationBottomSheetState extends State<ReservationBottomSheet> {
  final TextEditingController _restaurantController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 0);
  int _guests = 2;

  @override
  void dispose() {
    _restaurantController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              const Center(
                child: Text(
                  'Make a Reservation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Restaurant Field
              TextField(
                controller: _restaurantController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date Field
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_date),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Field
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _time.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Guests Field
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Number of Guests',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _guests > 1
                        ? () {
                      setState(() {
                        _guests--;
                      });
                    }
                        : null,
                  ),
                  Text(
                    _guests.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _guests < 20
                        ? () {
                      setState(() {
                        _guests++;
                      });
                    }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Special Requests
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Special Requests (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Any allergies or special requirements...',
                ),
              ),
              const SizedBox(height: 24),

              // Reserve Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reservation request sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Reserve Table'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String priceRange;
  final String imageUrl;
  final String address;
  final String description;
  final Map<String, String> openingHours;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.priceRange,
    required this.imageUrl,
    required this.address,
    required this.description,
    required this.openingHours,
  });
}

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share restaurant
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Add to favorites
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Cuisine
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          restaurant.cuisine,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and Price
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(' • '),
                        ],
                      ),

                      // Price Range
                      Text(
                        restaurant.priceRange,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        Icons.restaurant,
                        'Reserve',
                            () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const ReservationBottomSheet(),
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        Icons.map,
                        'Directions',
                            () {
                          // Open directions
                        },
                      ),
                      _buildActionButton(
                        context,
                        Icons.phone,
                        'Call',
                            () {
                          // Make call
                        },
                      ),
                      _buildActionButton(
                        context,
                        Icons.menu_book,
                        'Menu',
                            () {
                          // View menu
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Opening Hours
                  const Text(
                    'Opening Hours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...restaurant.openingHours.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(entry.value),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Photos Section
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Mock photo count
                      itemBuilder: (context, index) {
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[300],
                            image: index == 0
                                ? DecorationImage(
                              image: NetworkImage(restaurant.imageUrl),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: index == 0
                              ? null
                              : const Center(
                            child: Icon(Icons.photo, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Show all reviews
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sample Review
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Text('JD'),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'John Doe',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Icon(
                                          i < 4 ? Icons.star : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '2 weeks ago',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Amazing food and great ambiance! The crab dishes are a must-try. Definitely will be back on my next visit to Colombo.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const ReservationBottomSheet(),
          );
        },
        icon: const Icon(Icons.restaurant),
        label: const Text('Reserve Table'),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}