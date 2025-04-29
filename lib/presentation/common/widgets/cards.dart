import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// A collection of card widgets for the Taprobana Trails app

/// Base card with common styling and behavior
class BaseCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final BorderSide? border;
  final bool hasShadow;

  const BaseCard({
    super.key,
    required this.child,
    this.elevation = 2.0,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.onTap,
    this.border,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).cardColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Card with an image, title, and subtitle
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final Color? backgroundColor;
  final double borderRadius;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin = const EdgeInsets.all(0),
    this.elevation = 2.0,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      elevation: elevation,
      backgroundColor: backgroundColor,
      margin: margin,
      borderRadius: borderRadius,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surface,
                    highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60.0,
                    height: 60.0,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              )
            else if (leading != null)
              leading!,
            if (imageUrl != null || leading != null) 
              const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8.0),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Card for displaying places or attractions
class PlaceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? location;
  final double? rating;
  final int? reviewCount;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final double? distanceKm;
  final String? price;
  final bool isCompact;
  final EdgeInsetsGeometry? margin;

  const PlaceCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.location,
    this.rating,
    this.reviewCount,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.distanceKm,
    this.price,
    this.isCompact = false,
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      elevation: 3.0,
      margin: margin,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with overlay
          Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: AspectRatio(
                  aspectRatio: isCompact ? 16 / 9 : 3 / 2,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surface,
                      highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              
              // Favorite button overlay
              if (onFavoriteToggle != null)
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: onFavoriteToggle,
                      iconSize: 20.0,
                      constraints: const BoxConstraints(
                        minWidth: 36.0,
                        minHeight: 36.0,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                
              // Price tag if provided
              if (price != null)
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      price!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
                
              // Distance if provided
              if (distanceKm != null)
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me,
                          color: Colors.white,
                          size: 12.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '${distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Text content section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Subtitle if provided
                if (subtitle != null && !isCompact) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Location if provided
                if (location != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          location!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Rating if provided
                if (rating != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: rating!,
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
                      if (reviewCount != null) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          '($reviewCount)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification card for displaying alerts and updates
class NotificationCard extends StatelessWidget {
  final String title;
  final String? message;
  final DateTime time;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const NotificationCard({
    super.key,
    required this.title,
    this.message,
    required this.time,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.isRead = false,
    this.onTap,
    this.onDismiss,
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(time);
    final icoColor = iconColor ?? Theme.of(context).primaryColor;
    final icoBgColor = iconBackgroundColor ?? icoColor.withOpacity(0.1);
    
    final cardContent = BaseCard(
      elevation: isRead ? 1.0 : 2.0,
      backgroundColor: isRead 
          ? Theme.of(context).cardColor.withOpacity(0.8) 
          : Theme.of(context).cardColor,
      margin: margin,
      onTap: onTap,
      border: isRead 
          ? Border.all(color: Theme.of(context).dividerColor) 
          : null,
      hasShadow: !isRead,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: icoBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: icoColor,
                size: 24.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    // If dismissible, wrap the card in a Dismissible widget
    if (onDismiss != null) {
      return Dismissible(
        key: ValueKey(title + time.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: cardContent,
      );
    }
    
    return cardContent;
  }
  
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

/// Section card for grouping related content
class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final VoidCallback? onSeeAllPressed;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry contentPadding;
  final CrossAxisAlignment contentAlignment;
  final bool showDividers;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.onSeeAllPressed,
    this.margin = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.all(16.0),
    this.contentAlignment = CrossAxisAlignment.start,
    this.showDividers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              if (onSeeAllPressed != null)
                TextButton(
                  onPressed: onSeeAllPressed,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        
        // Content wrapper
        BaseCard(
          margin: margin,
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: contentAlignment,
              children: showDividers
                  ? _insertDividers(children, context)
                  : children,
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _insertDividers(List<Widget> widgets, BuildContext context) {
    final List<Widget> result = [];
    
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      
      if (i < widgets.length - 1) {
        result.add(Divider(
          height: 24.0,
          color: Theme.of(context).dividerColor,
        ));
      }
    }
    
    return result;
  }
}

/// Stats card for displaying metrics and analytics
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? subtitle;
  final bool isUp;
  final String? changePercentage;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.isUp = true,
    this.changePercentage,
    this.onTap,
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    final Color icoColor = iconColor ?? Theme.of(context).primaryColor;
    final Color bgColor = backgroundColor ?? icoColor.withOpacity(0.1);
    
    return BaseCard(
      onTap: onTap,
      margin: margin,
      borderRadius: 16.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    color: icoColor,
                    size: 20.0,
                  ),
                ),
                if (changePercentage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: isUp ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isUp ? Colors.green : Colors.red,
                          size: 12.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '$changePercentage%',
                          style: TextStyle(
                            color: isUp ? Colors.green : Colors.red,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4.0),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}