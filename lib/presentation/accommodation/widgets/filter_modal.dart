import 'package:flutter/material.dart';

class AccommodationFilterModal extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AccommodationFilterModal({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  State<AccommodationFilterModal> createState() =>
      _AccommodationFilterModalState();
}

class _AccommodationFilterModalState extends State<AccommodationFilterModal> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Accommodations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price Range
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RangeSlider(
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '${_filters['minPrice'] ?? 0}',
              '${_filters['maxPrice'] ?? 1000}',
            ),
            values: RangeValues(
              (_filters['minPrice'] ?? 0).toDouble(),
              (_filters['maxPrice'] ?? 1000).toDouble(),
            ),
            onChanged: (values) {
              setState(() {
                _filters['minPrice'] = values.start.round();
                _filters['maxPrice'] = values.end.round();
              });
            },
          ),

          // Rating Filter
          Text(
            'Minimum Rating',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Slider(
            min: 0,
            max: 5,
            divisions: 5,
            label: '${_filters['minRating'] ?? 0}',
            value: (_filters['minRating'] ?? 0).toDouble(),
            onChanged: (value) {
              setState(() {
                _filters['minRating'] = value;
              });
            },
          ),

          // Accommodation Type
          Text(
            'Accommodation Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildTypeChip('Hotel'),
              _buildTypeChip('Resort'),
              _buildTypeChip('Villa'),
              _buildTypeChip('Apartment'),
              _buildTypeChip('Hostel'),
            ],
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(_filters);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _filters['accommodationType'] == type;

    return FilterChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _filters['accommodationType'] = type;
          } else if (_filters['accommodationType'] == type) {
            _filters['accommodationType'] = null;
          }
        });
      },
    );
  }
}
