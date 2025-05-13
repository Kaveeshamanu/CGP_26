import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/itinerary.dart';
import '../services/offline_manager.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final List<Itinerary> _mockItineraries = [
    Itinerary(
      id: 'itinerary-1',
      name: 'Colombo City Tour',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      activities: [
        ItineraryActivity(
          id: 'activity-1',
          name: 'Visit Gangaramaya Temple',
          placeId: 'place-1',
          startTime: DateTime.now().add(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          notes: 'Remember to dress modestly',
        ),
        ItineraryActivity(
          id: 'activity-2',
          name: 'Lunch at Ministry of Crab',
          placeId: 'place-2',
          startTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
          endTime: DateTime.now().add(const Duration(hours: 5)),
          notes: 'Reservation confirmed',
        ),
        ItineraryActivity(
          id: 'activity-3',
          name: 'Shopping at Pettah Market',
          placeId: 'place-3',
          startTime: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
          endTime: DateTime.now().add(const Duration(hours: 7)),
          notes: 'Bring cash for bargaining',
        ),
      ],
      userId: 'user-1',
    ),
    Itinerary(
      id: 'itinerary-2',
      name: 'Kandy Adventure',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      activities: [
        ItineraryActivity(
          id: 'activity-4',
          name: 'Visit Temple of the Tooth',
          placeId: 'place-4',
          startTime: DateTime.now().add(const Duration(days: 3, hours: 10)),
          endTime: DateTime.now().add(const Duration(days: 3, hours: 12)),
          notes: 'Wear white if possible',
        ),
        ItineraryActivity(
          id: 'activity-5',
          name: 'Explore Royal Botanical Gardens',
          placeId: 'place-5',
          startTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
          endTime: DateTime.now().add(const Duration(days: 3, hours: 17)),
          notes: 'Bring water and snacks',
        ),
      ],
      userId: 'user-1',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final offlineManager = Provider.of<OfflineManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Itineraries'),
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
      body: _mockItineraries.isEmpty
          ? const Center(
        child: Text(
          'No itineraries yet. Create one to get started!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockItineraries.length,
        itemBuilder: (context, index) {
          final itinerary = _mockItineraries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItineraryDetailScreen(itinerary: itinerary),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itinerary.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isUpcoming(itinerary)
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _isUpcoming(itinerary) ? 'Upcoming' : 'Past',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('MMM d').format(itinerary.startDate)} - ${DateFormat('MMM d, yyyy').format(itinerary.endDate)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${itinerary.activities.length} activities',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.share, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateItineraryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  bool _isUpcoming(Itinerary itinerary) {
    return itinerary.endDate.isAfter(DateTime.now());
  }
}
class ItineraryDetailScreen extends StatelessWidget {
  final Itinerary itinerary;

  const ItineraryDetailScreen({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itinerary.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
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
        ],
      ),
      body: Column(
          children: [
      // Date Range Card
      Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('MMMM d').format(itinerary.startDate)} - ${DateFormat('MMMM d, yyyy').format(itinerary.endDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getDurationInDays(itinerary)} days',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calendar sync would be implemented here'),
                  ),
                );
              },
              icon: const Icon(Icons.sync),
              label: const Text('Sync'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    ),

    // Activities Timeline
    Expanded(
    child: ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: itinerary.activities.length,
    itemBuilder: (context, index) {
    final activity = itinerary.activities[index];
    return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Time Column
    Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Text(
    DateFormat('h:mm a').format(activity.startTime),
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 4),
    Container(
    width: 2,
    height: 40,
    color: Colors.grey[300],
    ),
    const SizedBox(height: 4),
    Text(
    DateFormat('h:mm a').format(activity.endTime),
    style: TextStyle(
    color: Colors.grey[700],
    ),
    ),
    ],
    ),
    const SizedBox(width: 16),

    // Activity Content
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    activity.name,
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    if (activity.notes != null) ...[
    Row(
    children: [
    const Icon(Icons.notes, size: 16, color: Colors.grey),
    const SizedBox(width: 4),
    Expanded(
    child: Text(
    activity.notes!,
    style: TextStyle(
    color: Colors.grey[700],
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 8),],
      Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to directions
            },
            icon: const Icon(Icons.directions, size: 16),
            label: const Text('Directions'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              // Show activity details
            },
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              textStyle: const TextStyle(fontSize: 12),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new activity
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  int _getDurationInDays(Itinerary itinerary) {
    return itinerary.endDate.difference(itinerary.startDate).inDays + 1;
  }
}
class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({super.key});

  @override
  _CreateItineraryScreenState createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  final List<String> _selectedInterests = [];
  final List<String> _availableInterests = [
    'History', 'Nature', 'Adventure', 'Culture', 'Food', 'Shopping', 'Beaches', 'Wildlife'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _createItinerary() {
    if (_formKey.currentState?.validate() ?? false) {
      // In a real app, you would save the itinerary to your backend

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinerary created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Itinerary'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Itinerary Name',
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your itinerary';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date Range
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(_startDate),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('to'),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectEndDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(_endDate),
                                ),
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
            const SizedBox(height: 24),

            // Interests
            Row(
              children: [
                const Icon(Icons.interests, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select your interests to personalize your itinerary',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableInterests.map((interest) {
                          final isSelected = _selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: isSelected,
                            onSelected: (_) => _toggleInterest(interest),
                            backgroundColor: Colors.grey[200],
                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            checkmarkColor: Theme.of(context).primaryColor,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Create Button
            ElevatedButton(
              onPressed: _createItinerary,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Itinerary'),
            ),
          ],
        ),
      ),
    );
  }
}
