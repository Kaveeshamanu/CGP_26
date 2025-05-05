import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../bloc/accommodation/accommodation_bloc.dart';
import '../../data/models/accommodation.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import '../../core/api/api_client.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/cards.dart';
import 'widgets/hotel_card.dart';
import 'widgets/amenity_list.dart';
import 'widgets/filter_modal.dart';

class AccommodationListScreen extends StatefulWidget {
  final String? destinationId;
  final String? destinationName;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? guestCount;

  const AccommodationListScreen({
    super.key,
    this.destinationId,
    this.destinationName,
    this.checkInDate,
    this.checkOutDate,
    this.guestCount,
  });

  @override
  State<AccommodationListScreen> createState() =>
      _AccommodationListScreenState();
}

class _AccommodationListScreenState extends State<AccommodationListScreen> {
  late AccommodationBloc _accommodationBloc;
  final _scrollController = ScrollController();
  late TextEditingController _searchController;
  DateTime? _selectedCheckInDate;
  DateTime? _selectedCheckOutDate;
  int _selectedGuestCount = 2;
  Map<String, dynamic> _filters = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCheckInDate =
        widget.checkInDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedCheckOutDate =
        widget.checkOutDate ?? DateTime.now().add(const Duration(days: 3));
    _selectedGuestCount = widget.guestCount ?? 2;

    _accommodationBloc = BlocProvider.of<AccommodationBloc>(context);

    // Load initial data
    if (widget.destinationId != null) {
      _accommodationBloc.add(LoadAccommodations(
        destinationId: widget.destinationId,
      ));
    } else {
      _accommodationBloc.add(LoadAccommodations());
    }

    // Add scroll listener for pagination if needed
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isSearching) {
      // If you need pagination, you might need to create a specific event for it
      // For now, we reload all accommodations with the same parameters
      if (widget.destinationId != null) {
        _accommodationBloc.add(LoadAccommodations(
          destinationId: widget.destinationId,
        ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _selectedCheckInDate!,
      end: _selectedCheckOutDate!,
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
        _selectedCheckInDate = pickedDateRange.start;
        _selectedCheckOutDate = pickedDateRange.end;
      });

      // Refresh the search with new dates
      _searchAccommodations();
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccommodationFilterModal(
        initialFilters: _filters,
        onApplyFilters: (filters) {
          setState(() {
            _filters = filters;
          });
          _searchAccommodations();
        },
      ),
    );
  }

  void _searchAccommodations() {
    setState(() {
      _isSearching = true;
    });

    final searchText = _searchController.text.trim();

    // Use FilterAccommodations instead of SearchAccommodations
    // since our bloc shows FilterAccommodations is handling filters
    _accommodationBloc.add(FilterAccommodations(
      filters: {
        'destinationId': widget.destinationId,
        'checkInDate': _selectedCheckInDate,
        'checkOutDate': _selectedCheckOutDate,
        'guestCount': _selectedGuestCount,
        'query': searchText.isNotEmpty ? searchText : null,
        'amenities': _filters['amenities'],
        'minPrice': _filters['minPrice'],
        'maxPrice': _filters['maxPrice'],
        'accommodationType': _filters['accommodationType'],
        'minRating': _filters['minRating'],
      },
    ));

    setState(() {
      _isSearching = false;
    });
  }

  String get _stayDuration {
    if (_selectedCheckInDate == null || _selectedCheckOutDate == null) {
      return '';
    }

    final nights =
        _selectedCheckOutDate!.difference(_selectedCheckInDate!).inDays;
    return '$nights ${nights == 1 ? 'night' : 'nights'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.destinationName != null
            ? 'Stays in ${widget.destinationName}'
            : 'Find Accommodations',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildDateAndGuestSelector(),
          Expanded(
            child: _buildAccommodationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search hotels, villas, etc.',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchAccommodations();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchAccommodations(),
        onChanged: (value) {
          if (value.isEmpty && _searchController.text.isNotEmpty) {
            _searchAccommodations();
          }
        },
      ),
    );
  }

  Widget _buildDateAndGuestSelector() {
    final dateFormat = DateFormat('MMM d');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18.0),
                    const SizedBox(width: 8.0),
                    Text(
                      '${dateFormat.format(_selectedCheckInDate!)} - ${dateFormat.format(_selectedCheckOutDate!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 18.0),
                  const SizedBox(width: 8.0),
                  Text(
                    '$_selectedGuestCount ${_selectedGuestCount == 1 ? 'guest' : 'guests'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuestCountPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Guest Count',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _selectedGuestCount > 1
                        ? () {
                            setState(() {
                              _selectedGuestCount--;
                            });
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      _selectedGuestCount.toString(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _selectedGuestCount < 10
                        ? () {
                            setState(() {
                              _selectedGuestCount++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _searchAccommodations();
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
  }

  Widget _buildAccommodationList() {
    return BlocBuilder<AccommodationBloc, AccommodationState>(
      builder: (context, state) {
        if (state is AccommodationInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AccommodationsLoading) {
          // Check if we have accommodations to show while loading
          if (_getAccommodationsFromState(state).isEmpty) {
            return _buildLoadingShimmer();
          }
        } else if (state is AccommodationsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _accommodationBloc.add(LoadAccommodations());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Get accommodations from the state
        final List<Accommodation> accommodations =
            _getAccommodationsFromState(state);

        if (accommodations.isEmpty && state is! AccommodationsLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hotel, size: 64.0, color: Colors.grey),
                const SizedBox(height: 16.0),
                Text(
                  'No accommodations found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Try adjusting your filters or search criteria',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _accommodationBloc.add(LoadAccommodations(
              destinationId: widget.destinationId,
            ));
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: accommodations.length +
                (state is AccommodationsLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == accommodations.length &&
                  state is AccommodationsLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final accommodation = accommodations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: HotelCard(
                  accommodation: accommodation,
                  checkInDate: _selectedCheckInDate,
                  checkOutDate: _selectedCheckOutDate,
                  guestCount: _selectedGuestCount,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/hotel_details',
                      arguments: {
                        'accommodation': accommodation,
                        'checkInDate': _selectedCheckInDate,
                        'checkOutDate': _selectedCheckOutDate,
                        'guestCount': _selectedGuestCount,
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper method to get accommodations from different states
  // Replace your existing helper method with this implementation
  List<Accommodation> _getAccommodationsFromState(AccommodationState state) {
    if (state is AccommodationsLoaded) {
      return state.accommodations;
    } else if (state is AccommodationsLoading) {
      return [];
    }
    return [];
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surface,
              highlightColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              child: Container(
                height: 250.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
