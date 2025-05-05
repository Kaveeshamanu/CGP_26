import 'package:flutter/material.dart';

/// A widget that displays a list of amenities with appropriate icons
class AmenityList extends StatelessWidget {
  final List<String> amenities;
  final int columns;
  final bool showDividers;

  const AmenityList({
    super.key,
    required this.amenities,
    this.columns = 2,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    // If no amenities, show placeholder
    if (amenities.isEmpty) {
      return const Center(
        child: Text('No amenities information available'),
      );
    }

    // Group amenities by category for better organization
    final Map<String, List<String>> categorizedAmenities =
        _categorizeAmenities();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categorizedAmenities.length,
      separatorBuilder: (context, index) => showDividers
          ? const Divider(height: 32.0)
          : const SizedBox(height: 24.0),
      itemBuilder: (context, index) {
        final category = categorizedAmenities.keys.elementAt(index);
        final categoryAmenities = categorizedAmenities[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            _buildAmenitiesGrid(context, categoryAmenities),
          ],
        );
      },
    );
  }

  Widget _buildAmenitiesGrid(
      BuildContext context, List<String> categoryAmenities) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 4.0,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: categoryAmenities.length,
      itemBuilder: (context, index) {
        final amenity = categoryAmenities[index];
        return _buildAmenityItem(context, amenity);
      },
    );
  }

  Widget _buildAmenityItem(BuildContext context, String amenity) {
    final icon = _getAmenityIcon(amenity);
    return Row(
      children: [
        Icon(icon, size: 18.0),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            amenity,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    // Map of amenities to their respective icons
    // ignore: non_constant_identifier_names
    var door_front = Icons.door_front_door;
    final Map<String, IconData> amenityIcons = {
      // Essentials
      'Wifi': Icons.wifi,
      'TV': Icons.tv,
      'Cable TV': Icons.tv,
      'Air conditioning': Icons.ac_unit,
      'Heating': Icons.whatshot,
      'Fan': Icons.toys,
      'Iron': Icons.iron,

      // Kitchen & Dining
      'Kitchen': Icons.kitchen,
      'Refrigerator': Icons.kitchen,
      'Microwave': Icons.microwave,
      'Dishes and silverware': Icons.set_meal,
      'Dishwasher': Icons.countertops,
      'Coffee maker': Icons.coffee,
      'Stove': Icons.local_fire_department,
      'Oven': Icons.local_fire_department,
      'BBQ grill': Icons.outdoor_grill,
      'Dining table': Icons.table_restaurant,

      // Bathroom
      'Hot water': Icons.hot_tub,
      'Shower': Icons.shower,
      'Bathtub': Icons.bathtub,
      'Hair dryer': Icons.dry,
      'Shampoo': Icons.sanitizer,
      'Towels': Icons.dry_cleaning,

      // Bedroom & Laundry
      'Washer': Icons.local_laundry_service,
      'Dryer': Icons.local_laundry_service,
      'Hangers': Icons.push_pin,
      'Bed linens': Icons.hotel,
      'Extra pillows and blankets': Icons.hotel,
      'Clothing storage': Icons.door_sliding,

      // Entertainment
      'Game console': Icons.gamepad,
      'Books and reading material': Icons.menu_book,
      'Board games': Icons.casino,
      'Sound system': Icons.speaker,

      // Outdoor
      'Patio or balcony': Icons.deck,
      'Garden or backyard': Icons.grass,
      'Pool': Icons.pool,
      'Hot tub': Icons.hot_tub,
      'Beach access': Icons.beach_access,
      'Outdoor furniture': Icons.chair,
      'Outdoor dining area': Icons.table_restaurant,
      // ignore: equal_keys_in_map
      'BBQ grill': Icons.outdoor_grill,
      'Free parking': Icons.local_parking,
      'Paid parking': Icons.local_parking,

      // Workspace
      'Dedicated workspace': Icons.laptop,
      'Office supplies': Icons.sticky_note_2,
      'Desk': Icons.desktop_windows,

      // Safety
      'Smoke alarm': Icons.smoke_free,
      'Carbon monoxide alarm': Icons.co2,
      'Fire extinguisher': Icons.fire_extinguisher,
      'First aid kit': Icons.medical_services,
      'Security cameras': Icons.videocam,
      'Safe': Icons.lock,

      // Accessibility
      'Elevator': Icons.elevator,
      'Step-free entrance': Icons.accessible,
      'Wide doorway': door_front,
      'Accessible bathroom': Icons.accessible,

      // Services
      'Breakfast': Icons.free_breakfast,
      'Cleaning before checkout': Icons.cleaning_services,
      'Long term stays allowed': Icons.date_range,
      '24-hour check-in': Icons.access_time,
      'Self check-in': Icons.vpn_key,
      'Building staff': Icons.support_agent,

      // Family
      'Crib': Icons.child_friendly,
      'High chair': Icons.chair,
      'Children\'s books and toys': Icons.toys,
      'Children\'s dinnerware': Icons.set_meal,

      // Other
      'Gym': Icons.fitness_center,
      'EV charger': Icons.electrical_services,
      'Private entrance': Icons.meeting_room,
      'Luggage dropoff allowed': Icons.luggage,
    };

    return amenityIcons[amenity] ?? Icons.check_circle_outline;
  }

  Map<String, List<String>> _categorizeAmenities() {
    // Define categories and which amenities belong to each
    final Map<String, List<String>> categoryDefinitions = {
      'Essentials': [
        'Wifi',
        'TV',
        'Cable TV',
        'Air conditioning',
        'Heating',
        'Fan',
        'Iron',
        'Essentials',
        'Towels',
        'Bed linens',
        'Soap',
        'Toilet paper'
      ],
      'Kitchen & Dining': [
        'Kitchen',
        'Refrigerator',
        'Microwave',
        'Dishes and silverware',
        'Dishwasher',
        'Coffee maker',
        'Stove',
        'Oven',
        'BBQ grill',
        'Dining table'
      ],
      'Bathroom': [
        'Hot water',
        'Shower',
        'Bathtub',
        'Hair dryer',
        'Shampoo',
        'Towels'
      ],
      'Bedroom & Laundry': [
        'Washer',
        'Dryer',
        'Hangers',
        'Bed linens',
        'Extra pillows and blankets',
        'Clothing storage'
      ],
      'Entertainment': [
        'Game console',
        'Books and reading material',
        'Board games',
        'Sound system',
        'TV',
        'Cable TV'
      ],
      'Outdoor': [
        'Patio or balcony',
        'Garden or backyard',
        'Pool',
        'Hot tub',
        'Beach access',
        'Outdoor furniture',
        'Outdoor dining area',
        'BBQ grill',
        'Free parking',
        'Paid parking'
      ],
      'Workspace': ['Dedicated workspace', 'Office supplies', 'Desk', 'Wifi'],
      'Safety': [
        'Smoke alarm',
        'Carbon monoxide alarm',
        'Fire extinguisher',
        'First aid kit',
        'Security cameras',
        'Safe'
      ],
      'Accessibility': [
        'Elevator',
        'Step-free entrance',
        'Wide doorway',
        'Accessible bathroom'
      ],
      'Services': [
        'Breakfast',
        'Cleaning before checkout',
        'Long term stays allowed',
        '24-hour check-in',
        'Self check-in',
        'Building staff'
      ],
      'Family': [
        'Crib',
        'High chair',
        'Children\'s books and toys',
        'Children\'s dinnerware'
      ],
      'Other': [
        'Gym',
        'EV charger',
        'Private entrance',
        'Luggage dropoff allowed'
      ],
    };

    // Create result map
    final Map<String, List<String>> result = {};

    // Track which amenities have been categorized
    final Set<String> categorizedAmenities = {};

    // First pass: categorize known amenities
    for (final category in categoryDefinitions.keys) {
      result[category] = [];
      for (final amenity in amenities) {
        if (categoryDefinitions[category]!.contains(amenity)) {
          result[category]!.add(amenity);
          categorizedAmenities.add(amenity);
        }
      }

      // Remove empty categories
      if (result[category]!.isEmpty) {
        result.remove(category);
      }
    }

    // Second pass: add uncategorized amenities to "Other"
    for (final amenity in amenities) {
      if (!categorizedAmenities.contains(amenity)) {
        if (!result.containsKey('Other')) {
          result['Other'] = [];
        }
        result['Other']!.add(amenity);
      }
    }

    return result;
  }
}
