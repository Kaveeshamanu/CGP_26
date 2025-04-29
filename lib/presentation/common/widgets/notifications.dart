import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../bloc/notification/notification_bloc.dart';
import '../../../bloc/notification/notification_event.dart';
import '../../../bloc/notification/notification_state.dart';
import '../../../data/models/notification.dart';

/// A collection of notification widgets and utilities for the Taprobana Trails app

/// In-app toast notification
class ToastNotification {
  /// Show a success toast message
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show an error toast message
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show an info toast message
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show a warning toast message
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

/// In-app notification banner that slides down from the top
class NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.message,
    this.type = NotificationType.general,
    this.icon,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    // Start the animation
    _controller.forward();
    
    // Set up auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  IconData _getIconForType() {
    switch (widget.type) {
      case NotificationType.success:
        return widget.icon ?? Icons.check_circle;
      case NotificationType.error:
        return widget.icon ?? Icons.error;
      case NotificationType.warning:
        return widget.icon ?? Icons.warning;
      case NotificationType.info:
        return widget.icon ?? Icons.info;
      case NotificationType.bookingConfirmed:
        return widget.icon ?? Icons.hotel;
      case NotificationType.tripReminder:
        return widget.icon ?? Icons.calendar_today;
      case NotificationType.dealAlert:
        return widget.icon ?? Icons.local_offer;
      case NotificationType.general:
      default:
        return widget.icon ?? Icons.notifications;
    }
  }

  Color _getColorForType() {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.bookingConfirmed:
        return Colors.purple;
      case NotificationType.tripReminder:
        return Colors.teal;
      case NotificationType.dealAlert:
        return Colors.amber;
      case NotificationType.general:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType();
    final icon = _getIconForType();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final cardColor = isDarkMode 
        ? Theme.of(context).cardColor
        : Colors.white;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          elevation: 4.0,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8.0, 
                bottom: 8.0,
                left: 16.0,
                right: 16.0,
              ),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(
                    color: color,
                    width: 3.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _dismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification badge that can be attached to icons or buttons
class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;
  final TextStyle? textStyle;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const NotificationBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 18.0,
    this.textStyle,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && child == null) {
      return const SizedBox.shrink();
    }
    
    final bgColor = color ?? Colors.red;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (child != null) child!,
        if (count > 0)
          Positioned(
            top: padding?.resolve(TextDirection.ltr).top ?? -5,
            right: padding?.resolve(TextDirection.ltr).right ?? -5,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: count > 99 ? BorderRadius.circular(size / 2) : null,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: textStyle ?? TextStyle(
                    color: Colors.white,
                    fontSize: size / 2 + 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget to display notification count and show indicator
class NotificationIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final VoidCallback? onTap;

  const NotificationIndicator({
    super.key,
    required this.icon,
    required this.label,
    this.iconSize = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsLoaded 
            ? state.unreadCount 
            : 0;
        
        return InkWell(
          onTap: onTap ?? () {
            Navigator.pushNamed(context, '/notification_center');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NotificationBadge(
                count: unreadCount,
                padding: const EdgeInsets.only(right: 2.0, top: 0.0),
                child: Icon(
                  icon,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A utility class for handling local notifications
class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // handle the notification tap when the app is in the foreground
      },
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // handle notification tap
      },
    );
  }
  
  /// Request notification permissions
  static Future<bool> requestPermission() async {
    // For iOS
    final bool? resultIOS = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // For Android 13 and higher
    final bool? resultAndroid = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    
    return resultIOS ?? resultAndroid ?? false;
  }
  
  /// Show an immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    bool isImportant = false,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'taprobana_trails_channel',
      'Taprobana Trails Notifications',
      channelDescription: 'Notifications from Taprobana Trails app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  /// Schedule a notification for a future time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    required dynamic UILocalNotificationDateInterpretation,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime.toLocal(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'taprobana_trails_scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled notifications from Taprobana Trails app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: payload, androidScheduleMode: null,
    );
  }
  
  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}

/// A manager for displaying in-app notification banners
class NotificationBannerManager {
  static OverlayEntry? _currentBanner;
  
  /// Show a notification banner
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    IconData? icon,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Dismiss current banner if it exists
    dismiss();
    
    // Create a new overlay entry
    _currentBanner = OverlayEntry(
      builder: (context) => NotificationBanner(
        title: title,
        message: message,
        type: type,
        icon: icon,
        onTap: onTap,
        onDismiss: dismiss,
        duration: duration,
      ),
    );
    
    // Show the banner
    Overlay.of(context).insert(_currentBanner!);
  }
  
  /// Dismiss the current banner if it exists
  static void dismiss() {
    if (_currentBanner != null) {
      _currentBanner!.remove();
      _currentBanner = null;
    }
  }
}