import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../../bloc/accommodation/accommodation_bloc.dart';
import '../../data/models/accommodation.dart';
import '../../data/models/user.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import '../../core/utils/connectivity.dart';
import '../../core/storage/secure_storage.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';

class BookingScreen extends StatefulWidget {
  final Accommodation? accommodation;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guestCount;

  const BookingScreen({
    super.key,
    this.accommodation,
    this.checkInDate,
    this.checkOutDate,
    this.guestCount = 2,
    required hotelId,
    required roomType,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late AccommodationBloc _accommodationBloc;
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int _guestCount;
  late double _totalPrice;
  bool _isLoading = false;
  bool _isAvailable = true;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _accommodationBloc = BlocProvider.of<AccommodationBloc>(context);
    _checkInDate =
        widget.checkInDate ?? DateTime.now().add(const Duration(days: 1));
    _checkOutDate =
        widget.checkOutDate ?? DateTime.now().add(const Duration(days: 3));
    _guestCount = widget.guestCount;

    _calculateTotalPrice();
    _checkAvailability('');
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = await SecureStorage().getCurrentUser();
      if (currentUser != null && mounted) {
        setState(() {
          _nameController.text = currentUser.displayName!;
          _emailController.text = currentUser.email;
          _phoneController.text = currentUser.phoneNumber ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  void _calculateTotalPrice() {
    // Calculate the total price based on accommodation's pricing model
    final nights = _checkOutDate.difference(_checkInDate).inDays;

    // Basic calculation based on base price
    double baseTotal = widget.accommodation?.basePrice * nights;

    // Add guest surcharge if more than standard occupancy
    final standardOccupancy = widget.accommodation?.standardOccupancy ?? 2;
    if (_guestCount > standardOccupancy) {
      final extraGuests = _guestCount - standardOccupancy;
      final extraGuestCharge =
          (widget.accommodation?.extraGuestCharge ?? 0) * extraGuests * nights;
      baseTotal += extraGuestCharge;
    }

    // Apply weekly or monthly discount if applicable
    if (nights >= 30 && widget.accommodation?.monthlyDiscount != null) {
      baseTotal =
          baseTotal * (1 - (widget.accommodation?.monthlyDiscount! / 100));
    } else if (nights >= 7 && widget.accommodation?.weeklyDiscount != null) {
      baseTotal =
          baseTotal * (1 - (widget.accommodation?.weeklyDiscount! / 100));
    }

    // Add cleaning fee if applicable
    if (widget.accommodation?.cleaningFee != null) {
      baseTotal += widget.accommodation?.cleaningFee!;
    }

    // Add service fee (assume 10% if not specified)
    final serviceFeePercent = widget.accommodation?.serviceFeePercent ?? 10;
    final serviceFee = baseTotal * (serviceFeePercent / 100);

    // Calculate final total
    _totalPrice = baseTotal + serviceFee;
  }

  // ignore: non_constant_identifier_names
  Future<void> _checkAvailability(dynamic ConnectivityHelper) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check internet connectivity first
      if (!await ConnectivityHelper.isConnected()) {
        throw Exception(
            'No internet connection. Please try again when you\'re online.');
      }

      // Check accommodation availability
      _accommodationBloc.add(AccommodationCheckAvailability(
        accommodationId: widget.accommodation?.id,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
      ));
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _checkInDate,
      end: _checkOutDate,
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _checkInDate = pickedDateRange.start;
        _checkOutDate = pickedDateRange.end;
      });

      _calculateTotalPrice();
      _checkAvailability('');
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> _completeBooking(ConnectivityService connectivityHelper) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'This accommodation is not available for the selected dates.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check internet connectivity
      final connectivityStatus = await connectivityHelper.checkConnectivity();
      if (connectivityStatus != ConnectivityStatus.connected) {
        throw Exception(
            'No internet connection. Please try again when you\'re online.');
      }

      // Get current user
      final User? currentUser = await SecureStorage().getCurrentUser();
      if (currentUser == null) {
        throw Exception('Please login to complete your booking.');
      }

      // Submit booking with the proper event
      _accommodationBloc.add(AccommodationBooking(
        accommodationId: widget.accommodation?.id,
        userId: currentUser.id,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        guestCount: _guestCount,
        totalPrice: _totalPrice,
        specialRequests: _specialRequestsController.text.trim(),
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
      ));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Failed to complete booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _nightCount {
    return _checkOutDate.difference(_checkInDate).inDays;
  }

  String get _formattedDateRange {
    final dateFormat = DateFormat('MMM d, yyyy');
    return '${dateFormat.format(_checkInDate)} - ${dateFormat.format(_checkOutDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Complete Your Booking',
        showBackButton: true,
      ),
      body: BlocConsumer<AccommodationBloc, AccommodationState>(
        listener: (context, state) {
          if (state is AccommodationAvailabilityChecked) {
            setState(() {
              _isAvailable = state.isAvailable;
              _isLoading = false;
              if (!state.isAvailable) {
                _errorMessage =
                    'This accommodation is not available for the selected dates.';
              } else {
                _errorMessage = null;
              }
            });
          } else if (state is AccommodationBookingSuccess) {
            // Navigate to booking confirmation screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/booking_confirmation',
              ModalRoute.withName('/home'),
              arguments: {
                'bookingId': state.bookingId,
                'accommodation': widget.accommodation,
                'checkInDate': _checkInDate,
                'checkOutDate': _checkOutDate,
                'guestCount': _guestCount,
                'totalPrice': _totalPrice,
              },
            );
          } else if (state is AccommodationsError) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildBookingForm(),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingForm() {
    final currencyFormat = NumberFormat.currency(
      symbol: widget.accommodation?.currencySymbol ?? '\$',
    );

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Accommodation summary
          _buildAccommodationSummary(),
          const SizedBox(height: 24.0),

          // Booking details section
          _buildSectionTitle('Booking Details'),
          _buildDateSelector(),
          _buildGuestSelector(),
          const SizedBox(height: 24.0),

          // Guest information section
          _buildSectionTitle('Guest Information'),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
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
          const SizedBox(height: 16.0),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          // Special requests
          _buildSectionTitle('Special Requests (Optional)'),
          _buildTextField(
            controller: _specialRequestsController,
            label: 'Any special requirements or requests?',
            maxLines: 3,
          ),
          const SizedBox(height: 24.0),

          // Price breakdown
          _buildSectionTitle('Price Details'),
          _buildPriceBreakdown(),
          const SizedBox(height: 24.0),

          // Error message if any
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 24.0),

          // Terms and conditions checkbox
          _buildTermsCheckbox(),
          const SizedBox(height: 24.0),

          // Book Now button
          ElevatedButton(
            onPressed: !_isAvailable
                ? null
                : () => _completeBooking(ConnectivityService()),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Confirm Booking - ${currencyFormat.format(_totalPrice)}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  Widget _buildAccommodationSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.accommodation?.imageUrls.first,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface,
                highlightColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                child: Container(
                  height: 150,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.accommodation!.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16.0),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        widget.accommodation!.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: widget.accommodation!.rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 16.0,
                      ignoreGestures: true,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '(${widget.accommodation?.reviewCount} reviews)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formattedDateRange,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '$_nightCount ${_nightCount == 1 ? 'night' : 'nights'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: InkWell(
        onTap: () => _showGuestCountPicker(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_guestCount ${_guestCount == 1 ? 'Guest' : 'Guests'}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.accommodation?.maxGuests != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Maximum: ${widget.accommodation?.maxGuests} guests',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.6),
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuestCountPicker() {
    final maxGuests = widget.accommodation?.maxGuests ?? 10;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        int tempGuestCount = _guestCount;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Number of Guests',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: tempGuestCount > 1
                            ? () {
                                setState(() {
                                  tempGuestCount--;
                                });
                              }
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          tempGuestCount.toString(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: tempGuestCount < maxGuests
                            ? () {
                                setState(() {
                                  tempGuestCount++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      this.setState(() {
                        _guestCount = tempGuestCount;
                      });
                      _calculateTotalPrice();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildPriceBreakdown() {
    final currencyFormat = NumberFormat.currency(
      symbol: widget.accommodation?.currencySymbol ?? '\$',
    );

    // Calculate breakdown components
    final nights = _nightCount;
    final baseNightlyPrice = widget.accommodation?.basePrice;
    final baseTotal = baseNightlyPrice * nights;

    // Extra guest charges if applicable
    double extraGuestCharge = 0;
    final standardOccupancy = widget.accommodation?.standardOccupancy ?? 2;
    if (_guestCount > standardOccupancy) {
      final extraGuests = _guestCount - standardOccupancy;
      extraGuestCharge =
          (widget.accommodation?.extraGuestCharge ?? 0) * extraGuests * nights;
    }

    // Discounts if applicable
    double discount = 0;
    String? discountLabel;
    if (nights >= 30 && widget.accommodation?.monthlyDiscount != null) {
      discount = baseTotal * (widget.accommodation?.monthlyDiscount! / 100);
      discountLabel =
          'Monthly discount (${widget.accommodation?.monthlyDiscount}%)';
    } else if (nights >= 7 && widget.accommodation?.weeklyDiscount != null) {
      discount = baseTotal * (widget.accommodation?.weeklyDiscount! / 100);
      discountLabel =
          'Weekly discount (${widget.accommodation?.weeklyDiscount}%)';
    }

    // Cleaning fee if applicable
    final cleaningFee = widget.accommodation?.cleaningFee ?? 0;

    // Service fee
    final serviceFeePercent = widget.accommodation?.serviceFeePercent ?? 10;
    final serviceFee = (baseTotal + extraGuestCharge - discount + cleaningFee) *
        (serviceFeePercent / 100);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            '${currencyFormat.format(baseNightlyPrice)} x $nights ${nights == 1 ? 'night' : 'nights'}',
            currencyFormat.format(baseTotal),
          ),
          if (extraGuestCharge > 0)
            _buildPriceRow(
              'Extra guest charge',
              currencyFormat.format(extraGuestCharge),
            ),
          if (discount > 0 && discountLabel != null)
            _buildPriceRow(
              discountLabel,
              '-${currencyFormat.format(discount)}',
              isDiscount: true,
            ),
          if (cleaningFee > 0)
            _buildPriceRow(
              'Cleaning fee',
              currencyFormat.format(cleaningFee),
            ),
          _buildPriceRow(
            'Service fee',
            currencyFormat.format(serviceFee),
          ),
          const Divider(height: 24.0),
          _buildPriceRow(
            'Total',
            currencyFormat.format(_totalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : isDiscount
                    ? Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.green)
                    : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  bool _termsAccepted = false;

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _termsAccepted = !_termsAccepted;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'I agree to the terms and conditions, including the cancellation policy.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
