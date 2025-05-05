import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// NotificationCard for displaying alerts and updates
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
      border: isRead ? Border.all(color: Theme.of(context).dividerColor) : null,
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.7),
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

/// BaseCard implementation with fixed border parameter
class BaseCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Border? border; // Changed this from BorderSide? to Border?
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
