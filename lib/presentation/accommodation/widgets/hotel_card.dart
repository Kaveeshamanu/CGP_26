import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/accommodation.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

/// A card widget for displaying accommodation information in lists
class HotelCard extends StatelessWidget {
  final Accommodation accommodation;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guestCount;
  final bool isCompact;
  final bool showDistance;
  final Function()? onTap;
  final Function()? onFavoriteToggle;
  final bool isFavorite;

  const HotelCard({
    super.key,
    required this.accommodation,
    this.checkInDate,
    this.checkOutDate,
    this.guestCount = 2,
    this.isCompact = false,
    this.showDistance = false,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final nightCount = checkInDate != null && checkOutDate != null
        ? checkOutDate!.difference(checkInDate!).inDays
        : 1;

    final totalPrice = accommodation.basePrice * nightCount;
    final priceFormat = NumberFormat.currency(
      symbol: accommodation.currencySymbol ?? '\$',
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
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
            // Image section with favorite button
            _buildImageSection(context),

            // Hotel information
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating & type
                  Row(
                    children: [
                      _buildRatingIndicator(),
                      const Spacer(),
                      _buildTypeIndicator(context),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Name
                  Text(
                    accommodation.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14.0),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          accommodation.address,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDistance &&
                          accommodation.distanceFromCenter != null)
                        Text(
                          '${accommodation.distanceFromCenter!.toStringAsFixed(1)} km from center',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Features
                  if (!isCompact && accommodation.features != null)
                    _buildFeaturesList(context),

                  // Price
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              priceFormat.format(accommodation.basePrice),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'per night',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (checkInDate != null && checkOutDate != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                priceFormat.format(totalPrice),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'total for $nightCount ${nightCount > 1 ? 'nights' : 'night'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: accommodation.imageUrls.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface,
                highlightColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                child: Container(
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
        ),

        // Favorite button
        if (onFavoriteToggle != null)
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: onFavoriteToggle,
                constraints: const BoxConstraints(
                  minHeight: 36.0,
                  minWidth: 36.0,
                ),
                iconSize: 20.0,
                padding: EdgeInsets.zero,
              ),
            ),
          ),

        // Special offers or badges
        if (accommodation.isTopRated! || accommodation.isFeatured)
          Positioned(
            top: 8.0,
            left: 8.0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: accommodation.isTopRated!
                    ? Colors.amber.withOpacity(0.9)
                    : Theme.of(context).primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                accommodation.isTopRated! ? 'Top Rated' : 'Featured',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),

        // Discount badge if applicable
        if (accommodation.weeklyDiscount != null ||
            accommodation.monthlyDiscount != null)
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                accommodation.monthlyDiscount != null
                    ? '${accommodation.monthlyDiscount}% off'
                    : '${accommodation.weeklyDiscount}% off',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingIndicator() {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: accommodation.rating,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 14.0,
          ignoreGestures: true,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {},
        ),
        const SizedBox(width: 4.0),
        Text(
          '(${accommodation.reviewCount})',
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeIndicator(BuildContext context) {
    final Map<String, IconData> typeIcons = {
      'Hotel': Icons.hotel,
      'Resort': Icons.beach_access,
      'Villa': Icons.house,
      'Apartment': Icons.apartment,
      'Cottage': Icons.cottage,
      'Guesthouse': Icons.home,
      'Hostel': Icons.people,
      'Boutique': Icons.star,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeIcons[accommodation.type] ?? Icons.hotel,
            size: 12.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            accommodation.type,
            semanticsLabel: 'Hotel',
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    // Icons for common features
    final Map<String, IconData> featureIcons = {
      'Wifi': Icons.wifi,
      'Air conditioning': Icons.ac_unit,
      'Kitchen': Icons.kitchen,
      'Pool': Icons.pool,
      'Free parking': Icons.local_parking,
      'Washer': Icons.local_laundry_service,
      'Gym': Icons.fitness_center,
      'Breakfast': Icons.free_breakfast,
    };

    // Get the top 3 features
    final features = accommodation.features?.take(3).toList() ?? [];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                featureIcons[feature] ?? Icons.check_circle_outline,
                size: 12.0,
              ),
              const SizedBox(width: 4.0),
              Text(
                feature,
                style: const TextStyle(fontSize: 10.0),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
