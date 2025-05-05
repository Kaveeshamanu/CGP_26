import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/destination.dart';
import '../../../config/theme.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  final bool featured;
  final bool compact;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.featured = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination image
              Stack(
                children: [
                  // Main image
                  AspectRatio(
                    aspectRatio: compact ? 1.5 : 1.2,
                    child: CachedNetworkImage(
                      imageUrl: destination.images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),

                  // Featured badge
                  if (featured)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Rating badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            destination.rating.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save button
                  if (!compact)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.bookmark_border,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Destination details
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination name
                    Text(
                      destination.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.regionName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (!compact) ...[
                      SizedBox(height: 8),

                      // Tags
                      SizedBox(
                        height: 24,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: destination.tags.length > 3
                              ? 3
                              : destination.tags.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 6),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTagColor(
                                    destination.tags[index], theme),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                destination.tags[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 8),

                      // Weather and additional info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Weather
                          Row(
                            children: [
                              Icon(
                                _getWeatherIcon(
                                    destination.currentWeather as double),
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${destination.currentWeather}°C',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),

                          // Best time to visit or price
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                              SizedBox(width: 4),
                              Text(
                                destination.bestTimeToVisit!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTagColor(String tag, ThemeData theme) {
    // Return different colors based on tag category
    switch (tag.toLowerCase()) {
      case 'beach':
      case 'diving':
      case 'surfing':
      case 'water sports':
        return Colors.blue;

      case 'mountain':
      case 'hiking':
      case 'trekking':
      case 'camping':
        return Colors.green;

      case 'cultural':
      case 'historical':
      case 'temple':
      case 'unesco':
      case 'heritage':
        return Colors.purple;

      case 'wildlife':
      case 'safari':
      case 'nature':
      case 'bird watching':
        return Colors.amber.shade800;

      case 'adventure':
      case 'extreme':
      case 'rafting':
        return Colors.red;

      case 'food':
      case 'culinary':
      case 'dining':
        return Colors.orange;

      case 'luxury':
      case 'spa':
      case 'wellness':
        return Colors.teal;

      case 'budget':
      case 'backpacking':
        return Colors.indigo;

      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getWeatherIcon(double temperature) {
    if (temperature >= 30) {
      return Icons.wb_sunny;
    } else if (temperature >= 20) {
      return Icons.wb_cloudy;
    } else if (temperature >= 15) {
      return Icons.cloud;
    } else {
      return Icons.ac_unit;
    }
  }
}
