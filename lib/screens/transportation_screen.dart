import 'package:flutter/material.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  String _selectedMode = 'Taxi';
  final List<String> _transportModes = ['Taxi', 'Car Rental', 'Bus', 'Train', 'Tuk Tuk'];

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime _departureDate = DateTime.now();
  TimeOfDay _departureTime = TimeOfDay.now();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _departureDate) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (picked != null && picked != _departureTime) {
      setState(() {
        _departureTime = picked;
      });
    }
  }

  void _searchTransport() {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both origin and destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to results screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportResultsScreen(
          from: _fromController.text,
          to: _toController.text,
          mode: _selectedMode,
          date: _departureDate,
          time: _departureTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transport Mode Selection
            const Text(
              'Transport Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _transportModes.length,
                itemBuilder: (context, index) {
                  final mode = _transportModes[index];
                  final isSelected = mode == _selectedMode;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMode = mode;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForMode(mode),
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[700],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mode,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // From and To Fields
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date and Time Fields
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_departureDate.day}/${_departureDate.month}/${_departureDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _departureTime.format(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchTransport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Search Transport Options'),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Access Section
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAccessItem(
              context,
              'Airport Transfer',
              Icons.flight,
              Colors.blue,
                  () {
                _fromController.text = 'Bandaranaike International Airport';
                _toController.text = 'Colombo';
                setState(() {
                  _selectedMode = 'Taxi';
                });
              },
            ),
            const SizedBox(height: 12),
            _buildQuickAccessItem(
              context,
              'Colombo to Galle',
              Icons.directions_car,
              Colors.orange,
                  () {
                _fromController.text = 'Colombo';
                _toController.text = 'Galle';
                setState(() {
                  _selectedMode = 'Taxi';
                });
              },
            ),
            const SizedBox(height: 12),
            _buildQuickAccessItem(
              context,
              'Colombo City Tour',
              Icons.tour,
              Colors.green,
                  () {
                _fromController.text = 'Your Hotel';
                _toController.text = 'Colombo City Tour';
                setState(() {
                  _selectedMode = 'Tuk Tuk';
                });
              },
            ),
            const SizedBox(height: 12),
            _buildQuickAccessItem(
              context,
              'Train to Kandy',
              Icons.train,
              Colors.red,
                  () {
                _fromController.text = 'Colombo Fort';
                _toController.text = 'Kandy';
                setState(() {
                  _selectedMode = 'Train';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'Taxi':
        return Icons.local_taxi;
      case 'Car Rental':
        return Icons.directions_car;
      case 'Bus':
        return Icons.directions_bus;
      case 'Train':
        return Icons.train;
      case 'Tuk Tuk':
        return Icons.electric_rickshaw;
      default:
        return Icons.directions;
    }
  }

  Widget _buildQuickAccessItem(
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
class TransportResultsScreen extends StatelessWidget {
  final String from;
  final String to;
  final String mode;
  final DateTime date;
  final TimeOfDay time;

  const TransportResultsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.mode,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // Mock transport options based on mode
    List<TransportOption> options = _getMockOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text('$mode Options'),
      ),
      body: Column(
        children: [
          // Journey Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle_outlined, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        from,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 7),
                  height: 20,
                  width: 2,
                  color: Colors.grey[400],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        to,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      time.format(context),
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: options.isEmpty
                ? const Center(
              child: Text(
                'No options available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option.provider,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              option.price,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Journey Time
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Journey time: ${option.duration}',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Vehicle Type
                        Row(
                          children: [
                            const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              option.vehicleType,
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Features
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: option.features.map((feature) {
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
                                feature,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Book Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Show booking confirmation
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Booking'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Provider: ${option.provider}'),
                                      const SizedBox(height: 4),
                                      Text('From: $from'),
                                      const SizedBox(height: 4),
                                      Text('To: $to'),
                                      const SizedBox(height: 4),
                                      Text('Date: ${date.day}/${date.month}/${date.year}'),
                                      const SizedBox(height: 4),
                                      Text('Time: ${time.format(context)}'),
                                      const SizedBox(height: 4),
                                      Text('Price: ${option.price}'),
                                    ],
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
                                            content: Text('Booking confirmed!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context); // Return to transportation screen
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Book Now'),
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

  List<TransportOption> _getMockOptions() {
    if (mode == 'Taxi') {
      return [
        TransportOption(
          provider: 'PickMe',
          price: 'LKR 2,500',
          duration: '45 mins',
          vehicleType: 'Sedan - Toyota Corolla',
          features: ['AC', 'English Speaking', '4 Passengers', 'Luggage Space'],
        ),
        TransportOption(
          provider: 'Uber',
          price: 'LKR 2,350',
          duration: '50 mins',
          vehicleType: 'Sedan - Honda Civic',
          features: ['AC', 'English Speaking', '4 Passengers', 'Luggage Space'],
        ),
        TransportOption(
          provider: 'Lanka Cabs',
          price: 'LKR 2,800',
          duration: '45 mins',
          vehicleType: 'SUV - Toyota Fortuner',
          features: ['AC', 'English Speaking', '6 Passengers', 'Extra Luggage Space'],
        ),
      ];
    } else if (mode == 'Train') {
      return [
        TransportOption(
          provider: 'Intercity Express',
          price: 'LKR 1,200',
          duration: '2.5 hours',
          vehicleType: 'First Class',
          features: ['AC', 'Reserved Seats', 'Food Service', 'Scenic Route'],
        ),
        TransportOption(
          provider: 'Regular Service',
          price: 'LKR 400',
          duration: '3 hours',
          vehicleType: 'Second Class',
          features: ['Reserved Seats', 'Scenic Route'],
        ),
        TransportOption(
          provider: 'Regular Service',
          price: 'LKR 150',
          duration: '3.5 hours',
          vehicleType: 'Third Class',
          features: ['Unreserved', 'Scenic Route'],
        ),
      ];
    } else if (mode == 'Bus') {
      return [
        TransportOption(
          provider: 'Lanka Ashok Leyland',
          price: 'LKR 300',
          duration: '2 hours',
          vehicleType: 'AC Bus',
          features: ['AC', 'Reserved Seats', 'Luggage Storage'],
        ),
        TransportOption(
          provider: 'CTB',
          price: 'LKR 180',
          duration: '2.5 hours',
          vehicleType: 'Regular Bus',
          features: ['Frequent Service', 'Local Stops'],
        ),
      ];
    } else if (mode == 'Car Rental') {
      return [
        TransportOption(
          provider: 'Malkey Rent A Car',
          price: 'LKR 4,500/day',
          duration: 'Self Drive',
          vehicleType: 'Toyota Corolla',
          features: ['AC', 'Automatic', 'Unlimited Mileage', 'Insurance Included'],
        ),
        TransportOption(
          provider: 'Budget Rent A Car',
          price: 'LKR 6,000/day',
          duration: 'Self Drive',
          vehicleType: 'Toyota RAV4',
          features: ['AC', 'Automatic', 'Unlimited Mileage', 'Insurance Included', '4x4'],
        ),
        TransportOption(
          provider: 'Kings Rent A Car',
          price: 'LKR 8,500/day',
          duration: 'With Driver',
          vehicleType: 'Toyota Prado',
          features: ['AC', 'Automatic', 'Unlimited Mileage', 'Insurance Included', 'English Speaking Driver'],
        ),
      ];
    } else if (mode == 'Tuk Tuk') {
      return [
        TransportOption(
          provider: 'PickMe Tuk',
          price: 'LKR 800',
          duration: '30 mins',
          vehicleType: 'Standard Tuk Tuk',
          features: ['Metered', 'App Tracking', 'Local Experience'],
        ),
        TransportOption(
          provider: 'City Tours Tuk',
          price: 'LKR 2,500',
          duration: '3 hours',
          vehicleType: 'Tour Tuk Tuk',
          features: ['English Speaking Driver', 'City Tour Included', 'Photo Stops'],
        ),
      ];
    }

    return [];
  }
}

class TransportOption {
  final String provider;
  final String price;
  final String duration;
  final String vehicleType;
  final List<String> features;

  TransportOption({
    required this.provider,
    required this.price,
    required this.duration,
    required this.vehicleType,
    required this.features,
  });
}