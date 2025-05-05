import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' show cos, sqrt, asin;

import '../../bloc/accommodation/accommodation_bloc.dart';
import '../../data/models/accommodation.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import '../../core/location/map_helper.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import 'widgets/amenity_list.dart';
import 'widgets/room_selector.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Accommodation? accommodation;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guestCount;

  const HotelDetailsScreen({
    super.key,
    this.accommodation,
    this.checkInDate,
    this.checkOutDate,
    this.guestCount = 2,
    required hotelId,
  });

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  late AccommodationBloc _accommodationBloc;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int _guestCount;
  bool _isAvailable = true;
  String? _errorMessage;
  bool _isFavorite = false;
  final List<Map<String, dynamic>> _reviews = [];

  // Expandable sections
  bool _isDescriptionExpanded = false;
  bool _isAmenitiesExpanded = false;
  bool _isLocationExpanded = false;
  bool _isReviewsExpanded = false;
  bool _isPoliciesExpanded = false;

  @override
  void initState() {
    super.initState();
    _accommodationBloc = BlocProvider.of<AccommodationBloc>(context);
    _checkInDate =
        widget.checkInDate ?? DateTime.now().add(const Duration(days: 1));
    _checkOutDate =
        widget.checkOutDate ?? DateTime.now().add(const Duration(days: 3));
    _guestCount = widget.guestCount;

    // Load additional data
    _loadAccommodationDetails();
    _checkFavoriteStatus();
    _checkAvailability();
  }

  void _loadAccommodationDetails() {
    _accommodationBloc.add(LoadAccommodationDetails(
      accommodationId: widget.accommodation?.id ?? '',
    ));
  }

  Future<void> _checkFavoriteStatus() async {
    setState(() {
      _isFavorite = widget.accommodation?.isSaved ?? false;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      _accommodationBloc.add(SaveAccommodation(
        userId: 'currentUserId', // Replace with actual user ID
        accommodationId: widget.accommodation?.id ?? '',
      ));
    } else {
      _accommodationBloc.add(UnsaveAccommodation(
        userId: 'currentUserId', // Replace with actual user ID
        accommodationId: widget.accommodation?.id ?? '',
      ));
    }
  }

  void _checkAvailability() {
    _accommodationBloc.add(AccommodationCheckAvailability(
      accommodationId: widget.accommodation?.id,
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
    ));
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

      _checkAvailability();
    }
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

  void _shareAccommodation() {
    final accommodationName = widget.accommodation?.name;
    final nightCount = _checkOutDate.difference(_checkInDate).inDays;

    Share.share(
      'Check out $accommodationName on Taprobana Trails! I\'m planning a $nightCount-night stay from ${DateFormat('MMM d, yyyy').format(_checkInDate)} to ${DateFormat('MMM d, yyyy').format(_checkOutDate)}.',
      subject: 'Check out this amazing place in Sri Lanka!',
    );
  }

  void _proceedToBooking() {
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

    Navigator.pushNamed(
      context,
      '/booking',
      arguments: {
        'accommodation': widget.accommodation,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
        'guestCount': _guestCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AccommodationBloc, AccommodationState>(
        listener: (context, state) {
          if (state is AccommodationDetailsLoaded) {
          } else if (state is AccommodationAvailabilityChecked) {
            setState(() {
              _isAvailable = state.isAvailable;
              if (!state.isAvailable) {
                _errorMessage =
                    'This accommodation is not available for the selected dates.';
              } else {
                _errorMessage = null;
              }
            });
          } else if (state is AccommodationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(),
                    _buildAccommodationHeader(),
                    _buildDateAndGuestSelector(),
                    _buildDivider(),
                    _buildDescriptionSection(),
                    _buildDivider(),
                    _buildAmenitiesSection(),
                    _buildDivider(),
                    _buildLocationSection(),
                    _buildDivider(),
                    _buildReviewsSection(state),
                    _buildDivider(),
                    _buildPoliciesSection(),
                    _buildDivider(),
                    // Host information if applicable
                    if (widget.accommodation?.hostName != null)
                      _buildHostSection(),
                    const SizedBox(height: 100.0), // Space for bottom bar
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0.0,
      floating: true,
      pinned: true,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share),
          ),
          onPressed: _shareAccommodation,
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 300.0,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: widget.accommodation?.imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surface,
                    highlightColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 16.0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                widget.accommodation?.imageUrls.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? Theme.of(context).primaryColor
                      : Colors.white.withOpacity(0.7),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccommodationHeader() {
    final currencyFormat = NumberFormat.currency(
      symbol: widget.accommodation?.currencySymbol ?? '\$',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.accommodation!.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormat.format(widget.accommodation?.basePrice),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'per night',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (widget.accommodation?.weeklyDiscount != null ||
                  widget.accommodation?.monthlyDiscount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    widget.accommodation?.monthlyDiscount != null
                        ? 'Up to ${widget.accommodation?.monthlyDiscount}% off'
                        : '${widget.accommodation?.weeklyDiscount}% weekly discount',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndGuestSelector() {
    final dateFormat = DateFormat('MMM d');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your stay',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateRange(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18.0),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dateFormat.format(_checkInDate)} - ${dateFormat.format(_checkOutDate)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${_checkOutDate.difference(_checkInDate).inDays} nights',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              InkWell(
                onTap: () => _showGuestCountPicker(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        '$_guestCount',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 32.0,
      thickness: 1.0,
      indent: 16.0,
      endIndent: 16.0,
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (_isDescriptionExpanded ||
              (widget.accommodation?.description.length ?? 0) < 300)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                widget.accommodation?.description ?? 'No description provided.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.accommodation?.description.substring(0, 300)}...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isDescriptionExpanded = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text('Read more'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8.0),
          if (widget.accommodation?.features != null &&
              widget.accommodation?.features!.isNotEmpty)
            Wrap(
              spacing: 16.0,
              runSpacing: 12.0,
              children: [
                // Show key features as highlight items
                ..._buildFeatureItems(),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = widget.accommodation?.features ?? [];
    final icons = {
      'Entire place': Icons.home,
      'Self check-in': Icons.vpn_key,
      'Superhost': Icons.verified_user,
      'Free cancellation': Icons.event_available,
      'Mountain view': Icons.landscape,
      'Ocean view': Icons.water,
      'Lake view': Icons.water,
      'Pool': Icons.pool,
      'Hot tub': Icons.hot_tub,
      'Gym': Icons.fitness_center,
      'Kitchen': Icons.kitchen,
      'Washer': Icons.local_laundry_service,
      'Dryer': Icons.local_laundry_service,
      'Air conditioning': Icons.ac_unit,
      'Heating': Icons.whatshot,
      'Wifi': Icons.wifi,
      'TV': Icons.tv,
      'Parking': Icons.local_parking,
      'Elevator': Icons.elevator,
      'Workspace': Icons.laptop,
    };

    return features.take(5).map((feature) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icons[feature] ?? Icons.check_circle_outline,
            size: 16.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildAmenitiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isAmenitiesExpanded = !_isAmenitiesExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amenities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  _isAmenitiesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (_isAmenitiesExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AmenityList(
                amenities: widget.accommodation?.amenities ?? [],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 12.0,
                    children: [
                      // Show only first 6 amenities when collapsed
                      ...(widget.accommodation?.amenities ?? [])
                          .take(6)
                          .map((amenity) => _buildAmenityItem(amenity)),
                    ],
                  ),
                  if ((widget.accommodation?.amenities.length ?? 0) > 6)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAmenitiesExpanded = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        'Show all ${widget.accommodation?.amenities.length} amenities',
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(String amenity) {
    final icons = {
      'Wifi': Icons.wifi,
      'TV': Icons.tv,
      'Kitchen': Icons.kitchen,
      'Washer': Icons.local_laundry_service,
      'Dryer': Icons.local_laundry_service,
      'Air conditioning': Icons.ac_unit,
      'Heating': Icons.whatshot,
      'Pool': Icons.pool,
      'Hot tub': Icons.hot_tub,
      'Free parking': Icons.local_parking,
      'Gym': Icons.fitness_center,
      'Breakfast': Icons.free_breakfast,
      'Indoor fireplace': Icons.fireplace,
      'Smoking allowed': Icons.smoking_rooms,
      'Laptop-friendly workspace': Icons.laptop,
      'First aid kit': Icons.medical_services,
      'Fire extinguisher': Icons.fire_extinguisher,
      'Carbon monoxide alarm': Icons.co2,
      'Smoke alarm': Icons.smoke_free,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icons[amenity] ?? Icons.check_circle_outline,
          size: 16.0,
        ),
        const SizedBox(width: 4.0),
        Text(
          amenity,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isLocationExpanded = !_isLocationExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  _isLocationExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: _isLocationExpanded ? 300.0 : 150.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              color: Theme.of(context).cardColor,
            ),
            clipBehavior: Clip.antiAlias,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.accommodation!.latitude,
                  widget.accommodation!.longitude,
                ),
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(widget.accommodation!.id),
                  position: LatLng(
                    widget.accommodation!.latitude,
                    widget.accommodation!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: widget.accommodation?.name,
                  ),
                ),
              },
              zoomControlsEnabled: _isLocationExpanded,
              scrollGesturesEnabled: _isLocationExpanded,
              zoomGesturesEnabled: _isLocationExpanded,
              mapToolbarEnabled: _isLocationExpanded,
              myLocationButtonEnabled: false,
            ),
          ),
          if (_isLocationExpanded &&
              widget.accommodation?.locationDescription != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                widget.accommodation?.locationDescription!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (_isLocationExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Getting around',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  // Show transportation options if available
                  if (widget.accommodation?.transportationOptions != null)
                    ...widget.accommodation?.transportationOptions!
                        .map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.directions, size: 16.0),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    const Text(
                      'No transportation information available.',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(AccommodationState state) {
    List<Map<String, dynamic>> reviews = [];

    if (state is AccommodationDetailsLoaded) {
      reviews = _reviews;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isReviewsExpanded = !_isReviewsExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Reviews',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18.0),
                        const SizedBox(width: 4.0),
                        Text(
                          '${widget.accommodation?.rating.toStringAsFixed(1)} (${widget.accommodation?.reviewCount})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isReviewsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (state is AccommodationDetailsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'No reviews yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show rating breakdown
                  _buildRatingBreakdown(reviews),
                  const SizedBox(height: 16.0),
                  // Show top reviews
                  ...reviews
                      .take(_isReviewsExpanded ? reviews.length : 3)
                      .map((review) => _buildReviewItem(review)),
                  if (!_isReviewsExpanded && reviews.length > 3)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isReviewsExpanded = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        'Show all ${reviews.length} reviews',
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(List<Map<String, dynamic>> reviews) {
    // Calculate rating categories (cleanliness, accuracy, communication, etc.)
    final Map<String, double> ratingCategories = {
      'Cleanliness': 0,
      'Accuracy': 0,
      'Communication': 0,
      'Location': 0,
      'Check-in': 0,
      'Value': 0,
    };

    if (reviews.isNotEmpty) {
      for (var review in reviews) {
        if (review['ratingCategories'] != null) {
          final categories = review['ratingCategories'] as Map<String, dynamic>;
          for (var entry in categories.entries) {
            if (ratingCategories.containsKey(entry.key)) {
              ratingCategories[entry.key] = ratingCategories[entry.key]! +
                  (entry.value as num).toDouble();
            }
          }
        }
      }

      // Calculate averages
      for (var key in ratingCategories.keys) {
        ratingCategories[key] = ratingCategories[key]! / reviews.length;
      }
    }

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: ratingCategories.entries.map((entry) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 64.0) / 2,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              RatingBar.builder(
                initialRating: entry.value,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 12.0,
                ignoreGestures: true,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final reviewDate = review['createdAt'] != null
        ? DateTime.tryParse(review['createdAt'] as String)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review['userPhotoUrl'] != null)
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    review['userPhotoUrl'] as String,
                  ),
                  radius: 16.0,
                )
              else
                CircleAvatar(
                  radius: 16.0,
                  child: Text(
                    (review['userName'] as String).isNotEmpty
                        ? (review['userName'] as String)[0].toUpperCase()
                        : 'G',
                  ),
                ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['userName'] as String? ?? 'Guest',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (reviewDate != null)
                    Text(
                      DateFormat('MMMM yyyy').format(reviewDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            review['comment'] as String? ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isPoliciesExpanded = !_isPoliciesExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Policies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  _isPoliciesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (_isPoliciesExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicyItem(
                      'Check-in', widget.accommodation?.checkInTime ?? '14:00'),
                  _buildPolicyItem('Check-out',
                      widget.accommodation?.checkOutTime ?? '12:00'),
                  if (widget.accommodation?.cancellationPolicy != null)
                    _buildPolicyItem('Cancellation',
                        widget.accommodation?.cancellationPolicy!),
                  if (widget.accommodation?.houseRules != null &&
                      widget.accommodation?.houseRules!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        Text(
                          'House Rules',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8.0),
                        ...widget.accommodation?.houseRules!.map((rule) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check, size: 16.0),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(rule),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPolicyItem(
                      'Check-in', widget.accommodation?.checkInTime ?? '14:00',
                      compact: true),
                  _buildPolicyItem('Check-out',
                      widget.accommodation?.checkOutTime ?? '12:00',
                      compact: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String title, String content,
      {bool compact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: compact ? FontWeight.normal : FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHostSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hosted by ${widget.accommodation?.hostName}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              if (widget.accommodation?.hostPhotoUrl != null)
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.accommodation?.hostPhotoUrl!,
                  ),
                  radius: 24.0,
                )
              else
                CircleAvatar(
                  radius: 24.0,
                  child: Text(
                    widget.accommodation?.hostName != null &&
                            widget.accommodation?.hostName!.isNotEmpty
                        ? widget.accommodation?.hostName![0].toUpperCase()
                        : 'H',
                  ),
                ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.accommodation?.hostSince != null)
                      Text(
                        'Host since ${DateFormat('MMMM yyyy').format(widget.accommodation?.hostSince!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (widget.accommodation?.hostResponseRate != null)
                      Text(
                        'Response rate: ${widget.accommodation?.hostResponseRate}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.accommodation?.hostDescription != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                widget.accommodation?.hostDescription!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final currencyFormat = NumberFormat.currency(
      symbol: widget.accommodation?.currencySymbol ?? '\$',
    );
    final nights = _checkOutDate.difference(_checkInDate).inDays;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currencyFormat.format(widget.accommodation?.basePrice)} / night',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$nights nights: ${currencyFormat.format(widget.accommodation?.basePrice * nights)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isAvailable ? _proceedToBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              _isAvailable ? 'Book Now' : 'Not Available',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
