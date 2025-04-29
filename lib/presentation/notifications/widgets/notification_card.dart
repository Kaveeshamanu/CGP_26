import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/theme.dart';
import '../../../data/models/notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onToggleImportant;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
    required this.onToggleImportant,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide(color: Colors.grey[300]!)
              : BorderSide.none,
        ),
        color: notification.isRead ? Colors.white : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: _getNotificationColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and timestamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeago.format(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Notification message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Bottom row with action and indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Action button
                          if (notification.actionText != null)
                            OutlinedButton(
                              onPressed: onTap,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _getNotificationColor(),
                                side: BorderSide(color: _getNotificationColor()),
                                minimumSize: const Size(0, 30),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: Text(notification.actionText!),
                            )
                          else
                            const SizedBox.shrink(),
                            
                          // Status indicators
                          Row(
                            children: [
                              // Unread indicator
                              if (!notification.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                
                              // Important toggle
                              IconButton(
                                icon: Icon(
                                  notification.isImportant
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 20,
                                ),
                                onPressed: onToggleImportant,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: notification.isImportant
                                    ? Colors.amber
                                    : Colors.grey[400],
                              ),
                            ],
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
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.itinerary:
        return Icons.map_outlined;
      case NotificationType.booking:
        return Icons.check_circle_outline;
      case NotificationType.deals:
        return Icons.local_offer_outlined;
      case NotificationType.system:
        return Icons.notifications_outlined;
      case NotificationType.alert:
        return Icons.warning_amber_outlined;
      case NotificationType.destination:
        return Icons.place_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.itinerary:
        return Colors.blue;
      case NotificationType.booking:
        return Colors.green;
      case NotificationType.deals:
        return Colors.orange;
      case NotificationType.system:
        return Colors.purple;
      case NotificationType.alert:
        return Colors.red;
      case NotificationType.destination:
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
}