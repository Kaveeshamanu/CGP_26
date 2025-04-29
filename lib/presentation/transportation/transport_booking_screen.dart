import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../data/models/transport.dart';
import '../../bloc/transport/transport_bloc.dart';
import '../../bloc/transport/transport_event.dart';
import '../../bloc/transport/transport_state.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';

class TransportBookingScreen extends StatefulWidget {
  final TransportOption transportOption;

  const TransportBookingScreen({
    super.key,
    required this.transportOption, required transportType,
  });

  @override
  State<TransportBookingScreen> createState() => _TransportBookingScreenState();
}

class _TransportBookingScreenState extends State<TransportBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _passengerCount = 1;
  String? _selectedClass;
  String? _selectedRoute;
  String? _pickupLocation;
  String? _dropoffLocation;
  String? _specialRequests;
  bool _isRoundTrip = false;
  DateTime? _returnDate;
  
  bool _isLoading = false;
  bool _isBookingConfirmed = false;
  Map<String, dynamic>? _bookingDetails;

  // Dynamically determine available options based on transport type
  List<String> _availableClasses = [];
  List<String> _availableRoutes = [];
  
  @override
  void initState() {
    super.initState();
    _initializeOptions();
  }

  void _initializeOptions() {
    // Set options based on transport type
    switch (widget.transportOption.type) {
      case TransportType.bus:
        _availableClasses = ['Economy', 'Luxury', 'Semi-Luxury', 'Express'];
        _availableRoutes = [
          'Colombo - Kandy',
          'Colombo - Galle',
          'Colombo - Jaffna',
          'Kandy - Nuwara Eliya',
          'Galle - Matara',
        ];
        break;
        
      case TransportType.train:
        _availableClasses = ['1st Class', '2nd Class', '3rd Class', 'Observation Deck'];
        _availableRoutes = [
          'Colombo Fort - Kandy',
          'Colombo Fort - Badulla',
          'Colombo Fort - Jaffna',
          'Colombo Fort - Galle',
          'Colombo Fort - Trincomalee',
        ];
        break;
        
      case TransportType.taxi:
      case TransportType.tuktuk:
        // No classes for taxis/tuk-tuks
        _availableClasses = [];
        _availableRoutes = [];
        break;
        
      case TransportType.car:
        _availableClasses = ['Economy', 'Compact', 'SUV', 'Luxury'];
        _availableRoutes = [];
        break;
        
      default:
        _availableClasses = [];
        _availableRoutes = [];
    }
    
    // Set default values
    if (_availableClasses.isNotEmpty) {
      _selectedClass = _availableClasses[0];
    }
    
    if (_availableRoutes.isNotEmpty) {
      _selectedRoute = _availableRoutes[0];
    }
  }

  Future<void> _selectDate(BuildContext context, {bool isReturnDate = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isReturnDate ? (_returnDate ?? _selectedDate.add(const Duration(days: 1))) : _selectedDate,
      firstDate: isReturnDate ? _selectedDate.add(const Duration(days: 1)) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isReturnDate) {
          _returnDate = picked;
        } else {
          _selectedDate = picked;
          // Reset return date if selected date is after return date
          if (_returnDate != null && _returnDate!.isBefore(_selectedDate)) {
            _returnDate = null;
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirmBooking() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      setState(() {
        _isLoading = true;
      });
      
      final bookingData = {
        'transportId': widget.transportOption.id,
        'transportType': widget.transportOption.type.toString(),
        'transportName': widget.transportOption.name,
        'date': _selectedDate.toIso8601String(),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'passengerCount': _passengerCount,
        'class': _selectedClass,
        'route': _selectedRoute,
        'pickupLocation': _pickupLocation,
        'dropoffLocation': _dropoffLocation,
        'specialRequests': _specialRequests,
        'isRoundTrip': _isRoundTrip,
        'returnDate': _returnDate?.toIso8601String(),
      };
      
      // Submit booking
      context.read<TransportBloc>().add(
        BookTransport(bookingData: bookingData),
      );
    }
  }

  String _getBookingTitle() {
    switch (widget.transportOption.type) {
      case TransportType.bus:
        return 'Bus Ticket';
      case TransportType.train:
        return 'Train Ticket';
      case TransportType.taxi:
        return 'Taxi Booking';
      case TransportType.tuktuk:
        return 'Tuk-Tuk Booking';
      case TransportType.car:
        return 'Car Rental';
      default:
        return 'Transportation Booking';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Book ${_getBookingTitle()}',
        showBackButton: true,
      ),
      body: BlocConsumer<TransportBloc, TransportState>(
        listener: (context, state) {
          if (state is TransportLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
          
          if (state is TransportBookingSuccess) {
            setState(() {
              _isBookingConfirmed = true;
              _bookingDetails = state.bookingDetails;
            });
          } else if (state is TransportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressLoader(),
            );
          }
          
          if (_isBookingConfirmed) {
            return _buildBookingConfirmationScreen();
          }
          
          return _buildBookingForm();
        },
      ),
    );
  }

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transport option details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTransportTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTransportTypeIcon(),
                        color: _getTransportTypeColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.transportOption.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTransportTypeString(),
                            style: TextStyle(
                              color: _getTransportTypeColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (widget.transportOption.priceInfo != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.transportOption.priceInfo!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time picker
            if (_shouldShowTimePicker())
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
            if (_shouldShowTimePicker())
              const SizedBox(height: 16),
            
            // Passenger count
            Row(
              children: [
                const Text(
                  'Passengers:',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _passengerCount > 1
                            ? () {
                                setState(() {
                                  _passengerCount--;
                                });
                              }
                            : null,
                        color: AppTheme.primaryColor,
                      ),
                      Text(
                        '$_passengerCount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _passengerCount < 10
                            ? () {
                                setState(() {
                                  _passengerCount++;
                                });
                              }
                            : null,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Class selection
            if (_availableClasses.isNotEmpty) ...[
              const Text(
                'Class:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedClass,
                    isExpanded: true,
                    hint: const Text('Select Class'),
                    items: _availableClasses.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedClass = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Route selection
            if (_availableRoutes.isNotEmpty) ...[
              const Text(
                'Route:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoute,
                    isExpanded: true,
                    hint: const Text('Select Route'),
                    items: _availableRoutes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRoute = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Pickup location
            if (_shouldShowPickupDropoff()) ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pickupLocation = value;
                },
              ),
              const SizedBox(height: 16),
              
              // Dropoff location
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Dropoff Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dropoff location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dropoffLocation = value;
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Round trip option
            if (_shouldShowRoundTrip())
              Row(
                children: [
                  Switch(
                    value: _isRoundTrip,
                    onChanged: (value) {
                      setState(() {
                        _isRoundTrip = value;
                        if (!value) {
                          _returnDate = null;
                        }
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Text(
                    'Round Trip',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
            // Return date picker
            if (_isRoundTrip && _shouldShowRoundTrip()) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context, isReturnDate: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Return Date',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _returnDate != null
                                ? DateFormat('EEE, MMM d, yyyy').format(_returnDate!)
                                : 'Select Return Date',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Special requests
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Special Requests (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
                hintText: 'Any special requirements or notes',
              ),
              maxLines: 2,
              onSaved: (value) {
                _specialRequests = value;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingConfirmationScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Success message
          const Text(
            'Booking Confirmed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Your ${_getBookingTitle()} has been successfully booked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Booking details card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getTransportTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getTransportTypeIcon(),
                          color: _getTransportTypeColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.transportOption.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTransportTypeString(),
                              style: TextStyle(
                                color: _getTransportTypeColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Booking reference
                  if (_bookingDetails != null && _bookingDetails!['referenceNumber'] != null) ...[
                    const Text(
                      'Booking Reference:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bookingDetails!['referenceNumber'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Date and time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_shouldShowTimePicker())
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Return date for round trips
                  if (_isRoundTrip && _returnDate != null) ...[
                    const Text(
                      'Return Date:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEE, MMM d, yyyy').format(_returnDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Passenger count and class
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Passengers:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_passengerCount',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedClass != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Class:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedClass!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  // Pickup and dropoff locations
                  if (_pickupLocation != null && _dropoffLocation != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Pickup Location:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pickupLocation!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dropoff Location:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dropoffLocation!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  
                  // Route
                  if (_selectedRoute != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Route:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedRoute!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  
                  // Special requests
                  if (_specialRequests != null && _specialRequests!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Special Requests:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _specialRequests!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  
                  // Total price
                  if (_bookingDetails != null && _bookingDetails!['totalPrice'] != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _bookingDetails!['totalPrice'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share booking details
                    final bookingDetails = 'Booking Reference: ${_bookingDetails?['referenceNumber'] ?? 'N/A'}\n'
                        'Transport: ${widget.transportOption.name}\n'
                        'Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}\n'
                        'Time: ${_selectedTime.format(context)}\n';
                    
                    // Share booking details
                    // Implementation would use share_plus package
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to itinerary or home screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/itinerary',
                      (route) => route.settings.name == '/home',
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('View Itinerary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTransportTypeColor() {
    switch (widget.transportOption.type) {
      case TransportType.bus:
        return Colors.green;
      case TransportType.train:
        return Colors.purple;
      case TransportType.taxi:
        return Colors.amber;
      case TransportType.tuktuk:
        return Colors.orange;
      case TransportType.car:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransportTypeIcon() {
    switch (widget.transportOption.type) {
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.train:
        return Icons.train;
      case TransportType.taxi:
        return Icons.local_taxi;
      case TransportType.tuktuk:
        return Icons.moped;
      case TransportType.car:
        return Icons.directions_car;
      default:
        return Icons.commute;
    }
  }

  String _getTransportTypeString() {
    switch (widget.transportOption.type) {
      case TransportType.bus:
        return 'Bus';
      case TransportType.train:
        return 'Train';
      case TransportType.taxi:
        return 'Taxi';
      case TransportType.tuktuk:
        return 'Tuk-Tuk';
      case TransportType.car:
        return 'Car Rental';
      default:
        return 'Transport';
    }
  }

  bool _shouldShowTimePicker() {
    // Time picker is relevant for all except car rentals
    return widget.transportOption.type != TransportType.car;
  }

  bool _shouldShowPickupDropoff() {
    // Pickup/dropoff is mainly for taxi and tuk-tuk
    return widget.transportOption.type == TransportType.taxi || 
           widget.transportOption.type == TransportType.tuktuk;
  }

  bool _shouldShowRoundTrip() {
    // Round trip is relevant for all except car rentals
    return widget.transportOption.type != TransportType.car;
  }
}