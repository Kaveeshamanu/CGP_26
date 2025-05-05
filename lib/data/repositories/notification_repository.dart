import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/notification.dart';

/// Repository for managing app notifications
class NotificationRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _preferences;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  final String _collectionPath = 'notifications';
  final String _prefsKey = 'local_notifications';

  /// Constructor that initializes dependencies
  NotificationRepository({
    required SharedPreferences preferences,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotificationsPlugin,
  })  : _preferences = preferences,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _localNotificationsPlugin =
            localNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  Future<void> init() async {
    final androidSettings =
        const AndroidInitializationSettings('@drawable/notification_icon');
    final iosSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  /// Request notification permissions
  /// Request notification permissions
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      // For newer versions of the plugin
      try {
        // Method to request permission for Android 13 (API level 33) and above
        final result = await _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission();
        return result ?? false;
      } catch (e) {
        // Fallback for older versions where the method might not exist
        debugPrint('Error requesting notification permission: $e');
        // On older Android versions, permissions were granted automatically
        return true;
      }
    }
    return false;
  }

  /// Stream of notifications for a specific user
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                  'createdAt': (doc.data()['createdAt'] as Timestamp?)
                      ?.toDate()
                      .toIso8601String(),
                }))
            .toList());
  }

  /// Get notifications for a specific user
  Future<List<AppNotification>> getNotifications(
      {required String userId}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromJson({
                'id': doc.id,
                ...doc.data(),
                'createdAt': (doc.data()['createdAt'] as Timestamp?)
                    ?.toDate()
                    .toIso8601String(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  /// Get unread notification count for a user
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection(_collectionPath).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark a notification as read (alternative method name)
  Future<void> markNotificationAsRead({required String notificationId}) async {
    return markAsRead(notificationId);
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();

    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Mark all notifications as read for a user (alternative method name)
  Future<void> markAllNotificationsAsRead({required String userId}) async {
    return markAllAsRead(userId);
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collectionPath).doc(notificationId).delete();
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    final batch = _firestore.batch();

    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Clear all notifications for a user (alternative method name)
  Future<void> clearAllNotifications({required String userId}) async {
    return deleteAllNotifications(userId);
  }

  /// Update notification settings for a user
  Future<void> updateNotificationSettings(
      {required String userId, required Map<String, bool> settings}) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationSettings': settings,
    });
  }

  /// Send a notification to a user (from the server)
  Future<String> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    final notificationData = {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'isRead': false,
      'data': data,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef =
        await _firestore.collection(_collectionPath).add(notificationData);

    return docRef.id;
  }

  /// Schedule a local notification
  // Make sure you have these imports at the top of your file

  Future<int> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // Generate a unique ID for the notification
    final notificationId = const Uuid().v4();
    final numericId = notificationId.hashCode.abs();

    // Create the notification details
    final androidDetails = AndroidNotificationDetails(
      'taprobana_trails_channel',
      'Taprobana Trails Notifications',
      channelDescription: 'Notifications from Taprobana Trails app',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
        htmlFormatContent: false,
        htmlFormatTitle: false,
      ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments:
          imageUrl != null ? [DarwinNotificationAttachment(imageUrl)] : null,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Store the notification data locally
    await _saveLocalNotification(
      id: numericId,
      title: title,
      body: body,
      type: type,
      scheduledDate: scheduledDate,
      data: data,
      imageUrl: imageUrl,
    );

    // Schedule the notification - this is where the fix is needed
    await _localNotificationsPlugin.zonedSchedule(
      numericId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'id': numericId.toString(),
        'type': type.toString().split('.').last,
        'data': data,
      }),
    );

    return numericId;
  }

  /// Show an immediate local notification
  Future<int> showLocalNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // Generate a unique ID for the notification
    final notificationId = const Uuid().v4();
    final numericId = notificationId.hashCode.abs();

    // Create the notification details
    AndroidNotificationDetails androidDetails;

    if (imageUrl != null) {
      // For image notifications, we need to handle this differently
      androidDetails = AndroidNotificationDetails(
        'taprobana_trails_channel',
        'Taprobana Trails Notifications',
        channelDescription: 'Notifications from Taprobana Trails app',
        importance: Importance.high,
        priority: Priority.high,
        // The constructor has changed in newer versions - we use a simpler one without big picture
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
          htmlFormatContent: false,
          htmlFormatTitle: false,
        ),
      );
    } else {
      // Regular notification without image
      androidDetails = AndroidNotificationDetails(
        'taprobana_trails_channel',
        'Taprobana Trails Notifications',
        channelDescription: 'Notifications from Taprobana Trails app',
        importance: Importance.high,
        priority: Priority.high,
      );
    }

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments:
          imageUrl != null ? [DarwinNotificationAttachment(imageUrl)] : null,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Store the notification data locally
    await _saveLocalNotification(
      id: numericId,
      title: title,
      body: body,
      type: type,
      scheduledDate: DateTime.now(),
      data: data,
      imageUrl: imageUrl,
    );

    // Show the notification
    await _localNotificationsPlugin.show(
      numericId,
      title,
      body,
      notificationDetails,
      payload: jsonEncode({
        'id': numericId.toString(),
        'type': type.toString().split('.').last,
        'data': data,
      }),
    );

    return numericId;
  }

  /// Cancel a scheduled local notification
  Future<void> cancelLocalNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
    await _removeLocalNotification(id);
  }

  /// Cancel all scheduled local notifications
  Future<void> cancelAllLocalNotifications() async {
    await _localNotificationsPlugin.cancelAll();
    await _preferences.remove(_prefsKey);
  }

  /// Get all local notifications
  Future<List<LocalNotification>> getLocalNotifications() async {
    final jsonString = _preferences.getString(_prefsKey);
    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) =>
              LocalNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing local notifications: $e');
      return [];
    }
  }

  /// Get a local notification by ID
  Future<LocalNotification?> getLocalNotificationById(int id) async {
    final notifications = await getLocalNotifications();
    return notifications
        .firstWhereOrNull((notification) => notification.id == id);
  }

  /// Save a local notification to SharedPreferences
  Future<void> _saveLocalNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    final notifications = await getLocalNotifications();

    // Remove if exists
    notifications.removeWhere((notification) => notification.id == id);

    // Add new notification
    notifications.add(LocalNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      scheduledDate: scheduledDate,
      data: data,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    ));

    // Convert to JSON and save
    final jsonList =
        notifications.map((notification) => notification.toJson()).toList();
    await _preferences.setString(_prefsKey, jsonEncode(jsonList));
  }

  /// Remove a local notification from SharedPreferences
  Future<void> _removeLocalNotification(int id) async {
    final notifications = await getLocalNotifications();

    // Remove notification
    notifications.removeWhere((notification) => notification.id == id);

    // Convert to JSON and save
    final jsonList =
        notifications.map((notification) => notification.toJson()).toList();
    await _preferences.setString(_prefsKey, jsonEncode(jsonList));
  }

  /// Get trips with upcoming notification reminders
  Future<List<Map<String, dynamic>>> getUpcomingTripReminders({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // This is a complex query that depends on your data model
    // This is a simplified example
    final snapshot = await _firestore
        .collection('itineraries')
        .where('userId', isEqualTo: userId)
        .where('startDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'],
        'startDate': (data['startDate'] as Timestamp).toDate(),
        'destinationName': data['destinationName'],
      };
    }).toList();
  }

  /// Create reminder notifications for upcoming trips
  Future<List<int>> createTripReminders(
      List<Map<String, dynamic>> trips) async {
    final notificationIds = <int>[];

    for (final trip in trips) {
      final tripDate = trip['startDate'] as DateTime;
      final reminderDate = tripDate.subtract(const Duration(days: 1));

      // Only create reminders for future trips
      if (reminderDate.isAfter(DateTime.now())) {
        final notificationId = await scheduleLocalNotification(
          title: 'Trip Reminder',
          body: 'Your trip to ${trip['destinationName']} starts tomorrow!',
          scheduledDate: reminderDate,
          type: NotificationType.tripReminder,
          data: {
            'tripId': trip['id'],
            'destinationName': trip['destinationName'],
          },
        );

        notificationIds.add(notificationId);
      }
    }

    return notificationIds;
  }
}

/// Local notification model
class LocalNotification {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledDate;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final DateTime createdAt;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledDate,
    this.data,
    this.imageUrl,
    required this.createdAt,
  });

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'scheduledDate': scheduledDate.toIso8601String(),
      'data': data,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
