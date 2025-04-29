import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../config/theme.dart';
import '../../../data/models/transport.dart';
import '../map_screen.dart';

class RoutePlanner extends StatefulWidget {
  final LatLng? origin;
  final LatLng? destination;
  final TravelMode travelMode;
  final TransportType transportType;
  final Function({LatLng? origin, LatLng? destination}) onSetPoints;
  final Function(TravelMode) onChangeTravelMode;
  final Function(TransportType) onChangeTransportType;
  final VoidCallback onClearRoute;

  const RoutePlanner({
    super.key,
    this.origin,
    this.destination,
    required this.travelMode,
    required this.transportType,
    required this.onSetPoints,
    required this.onChangeTravelMode,
    required this.onChangeTransportType,
    required this.onClearRoute,
  });

  @override
  State<RoutePlanner> createState() => _RoutePlannerState();
}

class _RoutePlannerState extends State<RoutePlanner> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize text controllers with coordinates if available
    if (widget.origin != null) {
      _originController.text = _formatLatLng(widget.origin!);
    }
    
    if (widget.destination != null) {
      _destinationController.text = _formatLatLng(widget.destination!);
    }
  }

  @override
  void didUpdateWidget(RoutePlanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update text controllers if coordinates change
    if (widget.origin != oldWidget.origin && widget.origin != null) {
      _originController.text = _formatLatLng(widget.origin!);
    }
    
    if (widget.destination != oldWidget.destination && widget.destination != null) {
      _destinationController.text = _formatLatLng(widget.destination!);
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  String _formatLatLng(LatLng position) {
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  LatLng? _parseLatLng(String text) {
    try {
      final parts = text.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        return LatLng(lat, lng);
      }
    } catch (e) {
      // Invalid format
    }
    return null;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _swapLocations() {
    final tempOrigin = widget.origin;
    final tempDestination = widget.destination;
    
    widget.onSetPoints(
      origin: tempDestination,
      destination: tempOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expanded/Collapsed header
            Row(
              children: [
                const Icon(Icons.directions, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Route Planner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: _toggleExpanded,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              
              // Origin and destination inputs
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Origin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _originController,
                          decoration: const InputDecoration(
                            hintText: 'Select starting point',
                            isDense: true,
                            prefixIcon: Icon(Icons.location_on, color: Colors.green),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final position = _parseLatLng(value);
                            if (position != null) {
                              widget.onSetPoints(origin: position);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: _swapLocations,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            hintText: 'Select destination',
                            isDense: true,
                            prefixIcon: Icon(Icons.location_on, color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final position = _parseLatLng(value);
                            if (position != null) {
                              widget.onSetPoints(destination: position);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Travel mode selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTravelModeOption(
                    icon: Icons.directions_car,
                    label: 'Driving',
                    mode: TravelMode.driving,
                  ),
                  _buildTravelModeOption(
                    icon: Icons.directions_walk,
                    label: 'Walking',
                    mode: TravelMode.walking,
                  ),
                  _buildTravelModeOption(
                    icon: Icons.directions_bike,
                    label: 'Cycling',
                    mode: TravelMode.bicycling,
                  ),
                  _buildTravelModeOption(
                    icon: Icons.directions_transit,
                    label: 'Transit',
                    mode: TravelMode.transit,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Additional transport options (for transit or local options)
              if (widget.travelMode == TravelMode.transit || widget.travelMode == TravelMode.driving)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transport Options',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTransportOption(
                            icon: Icons.directions_car,
                            label: 'Car',
                            type: TransportType.car,
                          ),
                          _buildTransportOption(
                            icon: Icons.directions_bus,
                            label: 'Bus',
                            type: TransportType.bus,
                          ),
                          _buildTransportOption(
                            icon: Icons.train,
                            label: 'Train',
                            type: TransportType.train,
                          ),
                          _buildTransportOption(
                            icon: FontAwesomeIcons.taxi,
                            label: 'Taxi',
                            type: TransportType.taxi,
                          ),
                          _buildTransportOption(
                            icon: FontAwesomeIcons.motorcycle,
                            label: 'Tuk-Tuk',
                            type: TransportType.tuktuk,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClearRoute,
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.origin != null && widget.destination != null
                          ? () {
                              // Hide expanded view after route calculation
                              setState(() {
                                _isExpanded = false;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Get Directions'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Collapsed view - show basic route info
              if (widget.origin != null && widget.destination != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Show origin and destination
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.circle_outlined,
                                color: Colors.green,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatLatLng(widget.origin!),
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatLatLng(widget.destination!),
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Show travel mode
                    _getTravelModeIcon(widget.travelMode),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTravelModeOption({
    required IconData icon,
    required String label,
    required TravelMode mode,
  }) {
    final isSelected = widget.travelMode == mode;
    
    return InkWell(
      onTap: () {
        widget.onChangeTravelMode(mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportOption({
    required IconData icon,
    required String label,
    required TransportType type,
  }) {
    final isSelected = widget.transportType == type;
    
    return InkWell(
      onTap: () {
        widget.onChangeTransportType(type);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTravelModeIcon(TravelMode mode) {
    IconData icon;
    Color color;
    
    switch (mode) {
      case TravelMode.driving:
        icon = Icons.directions_car;
        color = Colors.blue;
        break;
      case TravelMode.walking:
        icon = Icons.directions_walk;
        color = Colors.green;
        break;
      case TravelMode.bicycling:
        icon = Icons.directions_bike;
        color = Colors.orange;
        break;
      case TravelMode.transit:
        icon = Icons.directions_transit;
        color = Colors.purple;
        break;
      default:
        icon = Icons.directions_car;
        color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}