import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Model class representing a room option
class RoomOption {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final double price;
  final String? currencySymbol;
  final int maxOccupancy;
  final List<String> amenities;
  final int quantity;
  final bool refundable;
  final String? cancellationPolicy;
  final bool breakfast;
  
  const RoomOption({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.price,
    this.currencySymbol,
    required this.maxOccupancy,
    required this.amenities,
    required this.quantity,
    this.refundable = false,
    this.cancellationPolicy,
    this.breakfast = false,
  });
}

/// A widget for selecting room options during the booking process
class RoomSelector extends StatefulWidget {
  final List<RoomOption> roomOptions;
  final Function(RoomOption) onRoomSelected;
  final String? selectedRoomId;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int nightCount;
  
  const RoomSelector({
    super.key,
    required this.roomOptions,
    required this.onRoomSelected,
    this.selectedRoomId,
    this.checkInDate,
    this.checkOutDate,
    this.nightCount = 1,
  });

  @override
  State<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  String? _expandedRoomId;
  String? _selectedRoomId;
  
  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.selectedRoomId;
  }
  
  @override
  void didUpdateWidget(RoomSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRoomId != widget.selectedRoomId) {
      _selectedRoomId = widget.selectedRoomId;
    }
  }
  
  void _toggleRoomExpansion(String roomId) {
    setState(() {
      if (_expandedRoomId == roomId) {
        _expandedRoomId = null;
      } else {
        _expandedRoomId = roomId;
      }
    });
  }
  
  void _selectRoom(RoomOption room) {
    setState(() {
      _selectedRoomId = room.id;
    });
    widget.onRoomSelected(room);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Select Room Type',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Display dates if available
        if (widget.checkInDate != null && widget.checkOutDate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  '${DateFormat('MMM d, yyyy').format(widget.checkInDate!)} - ${DateFormat('MMM d, yyyy').format(widget.checkOutDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '(${widget.nightCount} ${widget.nightCount > 1 ? 'nights' : 'night'})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        // Room options list
        ...widget.roomOptions.map((room) => _buildRoomCard(context, room)),
      ],
    );
  }
  
  Widget _buildRoomCard(BuildContext context, RoomOption room) {
    final isExpanded = _expandedRoomId == room.id;
    final isSelected = _selectedRoomId == room.id;
    final currencyFormat = NumberFormat.currency(
      symbol: room.currencySymbol ?? '\$',
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).dividerColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room header section
          InkWell(
            onTap: () => _toggleRoomExpansion(room.id),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      width: 80.0,
                      height: 80.0,
                      child: CachedNetworkImage(
                        imageUrl: room.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.surface,
                          highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Room info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16.0),
                            const SizedBox(width: 4.0),
                            Text(
                              'Up to ${room.maxOccupancy} ${room.maxOccupancy > 1 ? 'guests' : 'guest'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(
                              room.breakfast ? Icons.free_breakfast : Icons.no_meals,
                              size: 16.0,
                              color: room.breakfast ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              room.breakfast ? 'Breakfast included' : 'No breakfast',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: room.breakfast ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(
                              room.refundable ? Icons.check_circle : Icons.cancel,
                              size: 16.0,
                              color: room.refundable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              room.refundable ? 'Refundable' : 'Non-refundable',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: room.refundable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price and arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(room.price),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'per night',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8.0),
                      Icon(
                        isExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded details section
          if (isExpanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                // Room description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    room.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // Room image carousel
                if (room.imageUrls.length > 1)
                  SizedBox(
                    height: 120.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: room.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: room.imageUrls[index],
                              width: 160.0,
                              height: 120.0,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Theme.of(context).colorScheme.surface,
                                // ignore: deprecated_member_use
                                highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey,
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Room amenities
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Amenities',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 8.0,
                        children: room.amenities.map((amenity) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, size: 16.0),
                              const SizedBox(width: 4.0),
                              Text(
                                amenity,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Cancellation policy if available
                if (room.cancellationPolicy != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancellation Policy',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          room.cancellationPolicy!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16.0),
              ],
            ),
          
          // Select button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _selectRoom(room),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).cardColor,
                foregroundColor: isSelected 
                    ? Colors.white 
                    : Theme.of(context).primaryColor,
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(
                isSelected ? 'Selected' : 'Select',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}