import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:taprobana_trails/bloc/reservation/reservation_bloc.dart';

import '../../bloc/restaurant/restaurant_bloc.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../data/models/restaurant.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/permissions.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';

class ReservationScreen extends StatefulWidget {
  final Restaurant? restaurant;

  const ReservationScreen({
    super.key,
    this.restaurant,
    required restaurantId,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Reservation parameters
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(hour: 19, minute: 0); // Default 7:00 PM
  int _guestCount = 2;
  String? _selectedArea;

  // Available times based on date selection
  List<TimeOfDay> _availableTimes = [];

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Generate available times for selected date
    _generateAvailableTimes();

    // Pre-fill form with user data if available
    _prefillUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _prefillUserData() {
    // This would typically come from your user repository or auth service
    // For this example, we'll hard-code some values
    _nameController.text = ''; // User's name would go here
    _emailController.text = ''; // User's email would go here
    _phoneController.text = ''; // User's phone would go here
  }

  void _generateAvailableTimes() {
    // This would typically come from the restaurant's availability API
    // For this example, we'll generate some times between opening and closing

    // Check if the selected date is today
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    // Generate time slots (usually from opening time to closing time)
    // For example: 12:00, 12:30, 13:00, etc.
    List<TimeOfDay> allTimes = [];

    // Sample opening hours: 11:00 AM to
    // 10:00 PM (22:00)
    int startHour = 11; // 11:00 AM
    int endHour = 22; // 10:00 PM

    // If today, don't show past times
    if (isToday) {
      final now = TimeOfDay.now();
      // Add 1 hour buffer for immediate reservations
      startHour = now.hour + 1;
      if (startHour > endHour) {
        // If current time is past operating hours, no slots available
        setState(() {
          _availableTimes = [];
        });
        return;
      }
    }

    // Generate time slots at 30-minute intervals
    for (int hour = startHour; hour <= endHour; hour++) {
      allTimes.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < endHour) {
        allTimes.add(TimeOfDay(hour: hour, minute: 30));
      }
    }

    // Remove some slots to simulate limited availability
    // In a real app, this would come from the restaurant's availability API
    setState(() {
      _availableTimes = allTimes;

      // If the selected time is not in available times, select the first available
      if (!_isTimeInAvailableTimes(_selectedTime)) {
        _selectedTime = _availableTimes.isNotEmpty
            ? _availableTimes.first
            : TimeOfDay(hour: 19, minute: 0);
      }
    });
  }

  bool _isTimeInAvailableTimes(TimeOfDay time) {
    return _availableTimes
        .any((t) => t.hour == time.hour && t.minute == time.minute);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(Duration(days: 30)), // Allow booking up to 30 days in advance
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      // Regenerate available times for new date
      _generateAvailableTimes();
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime); // Format as 7:00 PM
  }

  void _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_availableTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No available time slots for selected date'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create reservation request
      final reservationRequest = ReservationRequest(
        restaurantId: widget.restaurant!.id,
        date: _selectedDate,
        time: _selectedTime,
        guestCount: _guestCount,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        specialRequests: _specialRequestsController.text,
        area: _selectedArea,
      );

      // Submit reservation
      context.read<ReservationBloc>().add(
            SubmitReservation(request: reservationRequest),
          );

      // Navigate to confirmation screen
      // In a real app, you'd wait for the bloc state to confirm success
      // For this example, we'll simulate a successful reservation
      await Future.delayed(Duration(seconds: 2)); // Simulate processing time

      // Navigate to confirmation
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.reservationConfirmation,
        arguments: ReservationConfirmationArgs(
          restaurant: widget.restaurant!,
          date: _selectedDate,
          time: _selectedTime,
          guestCount: _guestCount,
          reservationId:
              'RES-${DateTime.now().millisecondsSinceEpoch}', // Sample ID
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit reservation: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Make a Reservation',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant info card
                    _buildRestaurantCard(),

                    SizedBox(height: 24),

                    // Reservation details section
                    Text(
                      'Reservation Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date picker
                    _buildDateSelector(),

                    SizedBox(height: 24),

                    // Time selector
                    _buildTimeSelector(),

                    SizedBox(height: 24),

                    // Guest count selector
                    _buildGuestSelector(),

                    SizedBox(height: 24),

                    // Seating area selector (if available)
                    _buildAreaSelector(),

                    SizedBox(height: 24),

                    // Contact details section
                    Text(
                      'Contact Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 24),

                    // Special requests
                    TextFormField(
                      controller: _specialRequestsController,
                      decoration: InputDecoration(
                        labelText: 'Special Requests (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                        hintText:
                            'e.g., Dietary restrictions, special occasions, preferred seating',
                      ),
                      maxLines: 3,
                    ),

                    SizedBox(height: 32),

                    // Terms and privacy policy
                    _buildTermsAndPrivacyText(),

                    SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed:
                          _availableTimes.isEmpty ? null : _submitReservation,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Reservation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRestaurantCard() {
    final theme = Theme.of(context);
    final restaurant = widget.restaurant;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Restaurant image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: restaurant!.images.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                    width: 80,
                    height: 80,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),

            SizedBox(width: 16),

            // Restaurant details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant!.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${restaurant.rating} (${restaurant.reviewCount} reviews)',
                        style: theme.textTheme.bodySmall,
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
  }

  Widget _buildDateSelector() {
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMMd().format(_selectedDate);
    final dayName = DateFormat.EEEE().format(_selectedDate);

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$dayName, $formattedDate',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Times',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        if (_availableTimes.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No available time slots',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Please select a different date',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableTimes.length,
              itemBuilder: (context, index) {
                final time = _availableTimes[index];
                final isSelected = time.hour == _selectedTime.hour &&
                    time.minute == _selectedTime.minute;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : theme.colorScheme.outline,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _formatTimeOfDay(time),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGuestSelector() {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Guests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Select how many people will be dining',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _guestCount > 1
                    ? () {
                        setState(() {
                          _guestCount--;
                        });
                      }
                    : null,
                color: _guestCount > 1
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_guestCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _guestCount < 20
                    ? () {
                        setState(() {
                          _guestCount++;
                        });
                      }
                    : null,
                color: _guestCount < 20
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAreaSelector() {
    final theme = Theme.of(context);

    // This would come from the restaurant's available areas
    // For this example, we'll hard-code some options
    final areas = [
      'Indoor',
      'Outdoor',
      'Bar',
      'Private Room',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Seating Area (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "We'll try to accommodate your preference",
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: areas.map((area) {
            final isSelected = _selectedArea == area;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedArea = isSelected ? null : area;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Text(
                  area,
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacyText() {
    final theme = Theme.of(context);

    return Text(
      'By confirming your reservation, you agree to our Terms of Service and Privacy Policy. '
      'A confirmation will be sent to your email.',
      style: TextStyle(
        fontSize: 12,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Helper model classes for reservation

class ReservationRequest {
  final String restaurantId;
  final DateTime date;
  final TimeOfDay time;
  final int guestCount;
  final String name;
  final String email;
  final String phone;
  final String specialRequests;
  final String? area;

  ReservationRequest({
    required this.restaurantId,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialRequests,
    this.area,
  });
}

class ReservationConfirmationArgs {
  final Restaurant restaurant;
  final DateTime date;
  final TimeOfDay time;
  final int guestCount;
  final String reservationId;

  ReservationConfirmationArgs({
    required this.restaurant,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.reservationId,
  });
}
