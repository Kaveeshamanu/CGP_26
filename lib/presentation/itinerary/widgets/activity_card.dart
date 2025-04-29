import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taprobana_trails/presentation/itinerary/widgets/calendar_view.dart';

import '../../../config/theme.dart';
import '../../../data/models/itinerary.dart';
import '../../common/widgets/loaders.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showTime;
  final bool isEditable;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showTime = true,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getCategoryColor(activity.category),
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                _buildImageHeader(context),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeAndCategory(),
                    const SizedBox(height: 4),
                    _buildTitle(),
                    const SizedBox(height: 4),
                    _buildLocation(),
                    if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildNotes(),
                    ],
                    const SizedBox(height: 8),
                    _buildFooter(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: activity.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressLoader(size: 24),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.error_outline,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeAndCategory() {
    final timeFormatter = DateFormat('h:mm a');
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showTime)
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                "${timeFormatter.format(activity.startTime)} - ${timeFormatter.format(activity.endTime)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getCategoryColor(activity.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getCategoryName(activity.category),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getCategoryColor(activity.category),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      activity.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            activity.location,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note_outlined,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity.notes!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price indicator if available
        if (activity.cost != null && activity.cost! > 0)
          Text(
            "${activity.cost!.toStringAsFixed(2)} USD",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          )
        else
          Text(
            "Free",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
        
        // Action buttons
        if (isEditable)
          Row(
            children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.blue,
                  onPressed: onEdit,
                ),
              if (onEdit != null && onDelete != null)
                const SizedBox(width: 16),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red,
                  onPressed: () {
                    // Confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Activity'),
                        content: const Text(
                          'Are you sure you want to delete this activity from your itinerary?'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete!();
                            },
                            child: const Text(
                              'DELETE',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }

  Color _getCategoryColor(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.attraction:
        return Colors.blue;
      case ActivityCategory.dining:
        return Colors.orange;
      case ActivityCategory.accommodation:
        return Colors.purple;
      case ActivityCategory.transportation:
        return Colors.green;
      case ActivityCategory.shopping:
        return Colors.pink;
      case ActivityCategory.event:
        return Colors.amber;
      case ActivityCategory.other:
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.attraction:
        return 'Attraction';
      case ActivityCategory.dining:
        return 'Dining';
      case ActivityCategory.accommodation:
        return 'Accommodation';
      case ActivityCategory.transportation:
        return 'Transport';
      case ActivityCategory.shopping:
        return 'Shopping';
      case ActivityCategory.event:
        return 'Event';
      case ActivityCategory.other:
      default:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(ActivityCategory category) {
    var activityCategory = ActivityCategory;
    switch (category) {
      case activityCategory.attraction:
        return FontAwesomeIcons.landmark;
      case ActivityCategory.dining:
        return FontAwesomeIcons.utensils;
      case ActivityCategory.accommodation:
        return FontAwesomeIcons.hotel;
      case ActivityCategory.transportation:
        return FontAwesomeIcons.bus;
      case ActivityCategory.shopping:
        return FontAwesomeIcons.cartShopping;
      case ActivityCategory.event:
        return FontAwesomeIcons.calendarDay;
      case ActivityCategory.other:
      default:
        return FontAwesomeIcons.ellipsis;
    }
  }
}

class ActivityCategory {
  // ignore: prefer_typing_uninitialized_variables
  static var attraction;
}

class CircularProgressLoader {
  const CircularProgressLoader();
}