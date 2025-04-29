import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/destination.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class DealCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final double discount;
  final DateTime validUntil;
  final String provider;
  final String destinationId;
  final String category; // hotel, restaurant, transport, activity
  final VoidCallback onTap;
  final bool featured;
  final String? promoCode;

  const DealCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.discount,
    required this.validUntil,
    required this.provider,
    required this.destinationId,
    required this.category,
    required this.onTap,
    this.featured = false,
    this.promoCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = validUntil.isBefore(DateTime.now());
    final formattedDate = DateFormat('MMM dd, yyyy').format(validUntil);
    final daysLeft = validUntil.difference(DateTime.now()).inDays;
    
    return GestureDetector(
      onTap: isExpired ? null : onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and discount badge
              Stack(
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
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
                        child: Center(
                          child: Icon(Icons.error_outline, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  
                  // Discount badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.grey : AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${discount.toInt()}% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  // Featured badge
                  if (featured)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  
                  // Expired overlay
                  if (isExpired)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'EXPIRED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: _getCategoryColor(category),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4),
                    
                    // Provider
                    Text(
                      provider,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Description
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Promo code (if available)
                    if (promoCode != null)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              promoCode!,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 16),
                    
                    // Valid until date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: isExpired 
                                ? Colors.red 
                                : daysLeft < 3 
                                  ? Colors.orange 
                                  : theme.colorScheme.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              isExpired 
                                ? 'Expired on $formattedDate' 
                                : 'Valid until $formattedDate',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isExpired 
                                  ? Colors.red 
                                  : daysLeft < 3 
                                    ? Colors.orange 
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        
                        // Days left
                        if (!isExpired)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: daysLeft < 3 
                                ? Colors.orange.withOpacity(0.2)
                                : theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              daysLeft == 0 
                                ? 'Last day!' 
                                : daysLeft == 1 
                                  ? '1 day left' 
                                  : '$daysLeft days left',
                              style: TextStyle(
                                color: daysLeft < 3 
                                  ? Colors.orange 
                                  : theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hotel':
      case 'accommodation':
        return Colors.purple;
      case 'restaurant':
      case 'dining':
        return Colors.orange;
      case 'transport':
      case 'transportation':
        return Colors.blue;
      case 'activity':
      case 'experience':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }
}

// Example on how to use this widget:
//
// DealCard(
//   id: 'deal123',
//   imageUrl: 'https://example.com/image.jpg',
//   title: 'Special Discount at Cinnamon Grand',
//   description: 'Enjoy 30% off on all room bookings during weekdays',
//   discount: 30.0,
//   validUntil: DateTime.now().add(Duration(days: 15)),
//   provider: 'Cinnamon Grand Colombo',
//   destinationId: 'colombo',
//   category: 'hotel',
//   onTap: () {
//     // Handle tap
//   },
//   featured: true,
//   promoCode: 'TAPROBAN30',
// )