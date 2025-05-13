import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/accommodation.dart';
import '../services/booking_service.dart';
import '../services/offline_manager.dart';

class AccommodationScreen extends StatefulWidget {
  const AccommodationScreen({super.key});

  @override
  State<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 500);
  String _selectedType = 'All';
  final List<String> _accommodationTypes = ['All', 'Hotel', 'Resort', 'Hostel', 'Boutique Hotel', 'Villa'];
  double _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    // Fetch accommodations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingService = Provider.of<BookingService>(context, listen: false);
      bookingService.fetchAccommodations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context);
    final offlineManager = Provider.of<OfflineManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
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
                hintText: 'Search accommodations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                // Filter accommodations based on search query
                setState(() {});
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: _accommodationTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Accommodations List
          Expanded(
            child: bookingService.isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : bookingService.accommodations.isEmpty
                ? const Center(
              child: Text(
                'No accommodations available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: bookingService.accommodations.length,
              itemBuilder: (context, index) {
                final accommodation = bookingService.accommodations[index];

                // Apply filters
                if (_selectedType != 'All' && accommodation.type != _selectedType) {
                  return const SizedBox.shrink();
                }
                if (accommodation.price < _priceRange.start ||
                    accommodation.price > _priceRange.end) {
                  return const SizedBox.shrink();
                }
                if (accommodation.rating < _selectedRating) {
                  return const SizedBox.shrink();
                }
                if (_searchController.text.isNotEmpty &&
                    !accommodation.name.toLowerCase().contains(
                        _searchController.text.toLowerCase())) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccommodationDetailScreen(
                            accommodation: accommodation,
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
                            accommodation.imageUrl,
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
                              // Type and Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Type
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
                                      accommodation.type,
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
                                        accommodation.rating.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Name
                              Text(
                                accommodation.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Price
                              Text(
                                '\${accommodation.price.toStringAsFixed(2)} per night',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Amenities
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: accommodation.amenities
                                    .take(3)
                                    .map((amenity) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      amenity,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
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
    );
  }
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _priceRange = const RangeValues(0, 500);
                            _selectedType = 'All';
                            _selectedRating = 0;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Price Range
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 500,
                    divisions: 10,
                    labels: RangeLabels(
                      '\${_priceRange.start.round()}',
                      '\${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),

                  // Rating
                  const SizedBox(height: 16),
                  const Text(
                    'Minimum Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _selectedRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _selectedRating.toString(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRating = value;
                      });
                    },
                  ),

                  // Apply Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // The filtered results will be shown based on the state variables
                        this.setState(() {});
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
class AccommodationDetailScreen extends StatefulWidget {
  final Accommodation accommodation;

  const AccommodationDetailScreen({
    Key? key,
    required this.accommodation,
  }) : super(key: key);

  @override
  _AccommodationDetailScreenState createState() => _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends State<AccommodationDetailScreen> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  int _guests = 2;
  bool _isBooking = false;

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate.isBefore(_checkInDate.add(const Duration(days: 1)))) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  int get _nights {
    return _checkOutDate.difference(_checkInDate).inDays;
  }

  double get _totalPrice {
    return widget.accommodation.price * _nights;
  }

  Future<void> _bookAccommodation() async {
    setState(() {
      _isBooking = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking confirmed at ${widget.accommodation.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: [
          // App Bar with Image
          SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              widget.accommodation.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing functionality would be implemented here'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to favorites'),
                  ),
                );
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
    // Name and Type
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Expanded(
    child: Text(
    widget.accommodation.name,
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
    widget.accommodation.type,
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
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    // Rating
    Row(
    children: [
    const Icon(Icons.star, color: Colors.amber),
    const SizedBox(width: 4),
    Text(
    '${widget.accommodation.rating.toString()} (123 reviews)',
    style: const TextStyle(
    fontSize: 16,
    ),
    ),
    ],
    ),

    // Price
    Text(
    '\$ ${widget.accommodation.price.toStringAsFixed(2)} per night',
    style: TextStyle(
    color: Theme.of(context).primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),

    // Description
    const Text(
    'Description',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    Text(
    widget.accommodation.description,
    style: const TextStyle(
    fontSize: 16,
    ),
    ),
    const SizedBox(height: 16),

    // Amenities
    const Text(
    'Amenities',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    Wrap(
    spacing: 8,
    runSpacing: 8,
    children: widget.accommodation.amenities.map((amenity) {
    return Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
    ),
    decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(20),
    ),
    child: Text(amenity),
    );
    }).toList(),
    ),
    const SizedBox(height: 16),

    // Location
    const Text(
    'Location',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    Container(
    height: 200,
    decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(8),
    ),
    child: const Center(
    child: Text(
    'Map would be displayed here',
    style: TextStyle(
    color: Colors.grey,
    ),
    ),
    ),
    ),
    const SizedBox(height: 16),

    // Booking Form
    const Text(
    'Book Your Stay',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),

    // Check-in and Check-out
    Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Check-in',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    InkWell(
    onTap: () => _selectCheckInDate(context),
    child: InputDecorator(
    decoration: const InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
    ),
    ),
    child: Text(
    DateFormat('MMM d, yyyy').format(_checkInDate),
    ),
    ),
    ),
    ],
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
      'Check-out',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
      SizedBox(height: 8),
      InkWell(
        onTap: () => _selectCheckOutDate(context),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          child: Text(
            DateFormat('MMM d, yyyy').format(_checkOutDate),
          ),
        ),
      ),
      ],
    ),
    ),
    ],
    ),
      const SizedBox(height: 16),

      // Guests
      Row(
        children: [
          const Text(
            'Guests',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
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
            onPressed: _guests < 10
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

      // Price Summary
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${widget.accommodation.price.toStringAsFixed(2)} x $_nights nights',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service fee', style: TextStyle(fontSize: 16)),
                Text('\$25.00', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${(_totalPrice + 25).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Book Now Button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isBooking ? null : _bookAccommodation,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isBooking
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Book Now'),
        ),
      ),
    ],
    ),
        ),
        ),
          ],
        ),
    );
  }
}