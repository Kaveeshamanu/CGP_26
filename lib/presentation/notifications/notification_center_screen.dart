import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../data/models/notification.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import 'widgets/notification_card.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load notifications when screen is opened
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isRefreshing = true;
    });
    
    // Reload notifications
    context.read<NotificationBloc>().add(LoadNotifications(forceRefresh: true));
    
    // Wait for a short delay to show the refreshing indicator
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  void _markAllAsRead() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
            },
            child: Text(
              'MARK ALL',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationBloc>().add(ClearAllNotifications());
            },
            child: const Text(
              'CLEAR ALL',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark the notification as read if it isn't already
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id));
    }
    
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.itinerary:
        Navigator.pushNamed(
          context,
          '/itinerary_details',
          arguments: {'itineraryId': notification.referenceId},
        );
        break;
      
      case NotificationType.booking:
        Navigator.pushNamed(
          context,
          '/booking_details',
          arguments: {'bookingId': notification.referenceId},
        );
        break;
      
      case NotificationType.deal:
        Navigator.pushNamed(
          context,
          '/deal_details',
          arguments: {'dealId': notification.referenceId},
        );
        break;
      
      case NotificationType.system:
      case NotificationType.alert:
        // Just mark as read, no navigation
        break;
      
      case NotificationType.destination:
        Navigator.pushNamed(
          context,
          '/destination_details',
          arguments: {'destinationId': notification.referenceId},
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
          
          if (state is NotificationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          
          if (state is NotificationOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Tab bar
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Unread'),
                  Tab(text: 'Important'),
                ],
              ),
              
              // Tab bar view
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshNotifications,
                  color: AppTheme.primaryColor,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All notifications
                      _buildNotificationList(
                        context,
                        filter: (notification) => true,
                      ),
                      
                      // Unread notifications
                      _buildNotificationList(
                        context,
                        filter: (notification) => !notification.isRead,
                      ),
                      
                      // Important notifications
                      _buildNotificationList(
                        context,
                        filter: (notification) => 
                          notification.isImportant || 
                          notification.type == NotificationType.alert,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
            return BottomAppBar(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _markAllAsRead(),
                        icon: const Icon(Icons.done_all),
                        label: const Text('Mark All as Read'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _clearAllNotifications(),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context, {
    required bool Function(AppNotification) filter,
  }) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading && !_isRefreshing) {
          return const Center(
            child: CircularProgressLoader(),
          );
        }
        
        if (state is NotificationsLoaded) {
          final notifications = state.notifications.where(filter).toList();
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          
          // Group notifications by date
          final groupedNotifications = _groupNotificationsByDate(notifications);
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedNotifications.length,
            itemBuilder: (context, index) {
              final date = groupedNotifications.keys.elementAt(index);
              final notificationsForDate = groupedNotifications[date]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _formatGroupDate(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  // Notifications for this date
                  ...notificationsForDate.map((notification) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: NotificationCard(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () {
                          context.read<NotificationBloc>().add(
                            DeleteNotification(notification.id),
                          );
                        },
                        onToggleImportant: () {
                          context.read<NotificationBloc>().add(
                            ToggleNotificationImportance(notification.id),
                          );
                        },
                      ),
                    );
                  }),
                  
                  // Add some space between date groups
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        }
        
        // Default empty state
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! Check back later for updates on your trips, bookings, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<AppNotification>> _groupNotificationsByDate(
    List<AppNotification> notifications,
  ) {
    final Map<DateTime, List<AppNotification>> groupedNotifications = {};
    
    for (final notification in notifications) {
      // Get just the date part (ignore time)
      final date = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );
      
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      
      groupedNotifications[date]!.add(notification);
    }
    
    // Sort dates in descending order (newest first)
    final sortedDates = groupedNotifications.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    // Create a new map with sorted dates
    final sortedGroupedNotifications = <DateTime, List<AppNotification>>{};
    for (final date in sortedDates) {
      // Sort notifications by timestamp (newest first)
      final sortedNotifications = groupedNotifications[date]!
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
      sortedGroupedNotifications[date] = sortedNotifications;
    }
    
    return sortedGroupedNotifications;
  }

  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else if (date.isAfter(DateTime(now.year, now.month, now.day - 7))) {
      // Within the last week, show day name
      return DateFormat('EEEE').format(date); // e.g., "Monday"
    } else if (date.year == now.year) {
      // This year, show month and day
      return DateFormat('MMMM d').format(date); // e.g., "July 10"
    } else {
      // Different year, show full date
      return DateFormat('MMMM d, y').format(date); // e.g., "July 10, 2022"
    }
  }
}