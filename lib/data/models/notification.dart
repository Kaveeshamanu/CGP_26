import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

/// Type of notification.
enum NotificationType {
  booking,
  deals,
  reminder,
  system,
  itinerary,
  social,
  weather,
  travel,
  general,
  success,
  error,
  warning,
  info,
  bookingConfirmed,
  tripReminder,
  dealAlert,
  alert,
  destination,
}

/// Notification model for the application.
@JsonSerializable()
class AppNotification extends Equatable {
  /// The unique identifier of the notification.
  final String id;

  /// The user ID this notification belongs to.
  final String userId;

  /// The title of the notification.
  final String title;

  /// The body text of the notification.
  final String body;

  /// The type of the notification.
  final NotificationType type;

  /// Whether the notification has been read.
  final bool isRead;

  /// The creation date of the notification.
  final DateTime createdAt;

  /// The action link for the notification (optional).
  final String? actionLink;

  /// The action text for the notification (optional).
  final String? actionText;

  /// The image URL for the notification (optional).
  final String? imageUrl;

  /// The reference ID for linked entities (e.g., booking ID, itinerary ID).
  final String? referenceId;

  /// Additional data for the notification in JSON format.
  final Map<String, dynamic>? data;

  /// Creates a new AppNotification.
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.actionLink,
    this.actionText,
    this.imageUrl,
    this.referenceId,
    this.data,
  });

  /// Factory constructor that creates an [AppNotification] from JSON.
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  /// Converts this [AppNotification] to JSON.
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  /// Creates a copy of this [AppNotification] with the given fields replaced with new values.
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? actionLink,
    String? actionText,
    String? imageUrl,
    String? referenceId,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionLink: actionLink ?? this.actionLink,
      actionText: actionText ?? this.actionText,
      imageUrl: imageUrl ?? this.imageUrl,
      referenceId: referenceId ?? this.referenceId,
      data: data ?? this.data,
    );
  }

  /// Gets the icon for the notification type.
  String get typeIcon {
    switch (type) {
      case NotificationType.booking:
        return 'event_available';
      case NotificationType.deals:
        return 'local_offer';
      case NotificationType.reminder:
        return 'access_alarm';
      case NotificationType.system:
        return 'info';
      case NotificationType.itinerary:
        return 'date_range';
      case NotificationType.social:
        return 'group';
      case NotificationType.weather:
        return 'wb_sunny';
      case NotificationType.travel:
        return 'flight';
      case NotificationType.general:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.success:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.error:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.warning:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.info:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.bookingConfirmed:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.tripReminder:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.dealAlert:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.alert:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.destination:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Gets the color for the notification type.
  int get typeColor {
    switch (type) {
      case NotificationType.booking:
        return 0xFF4CAF50; // Green
      case NotificationType.deals:
        return 0xFFF44336; // Red
      case NotificationType.reminder:
        return 0xFFFF9800; // Orange
      case NotificationType.system:
        return 0xFF2196F3; // Blue
      case NotificationType.itinerary:
        return 0xFF9C27B0; // Purple
      case NotificationType.social:
        return 0xFF3F51B5; // Indigo
      case NotificationType.weather:
        return 0xFFFFEB3B; // Yellow
      case NotificationType.travel:
        return 0xFF009688; // Teal
      case NotificationType.general:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.success:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.error:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.warning:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.info:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.bookingConfirmed:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.tripReminder:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.dealAlert:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.alert:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.destination:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Gets the relative time since the notification was created.
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        isRead,
        createdAt,
        actionLink,
        actionText,
        imageUrl,
        referenceId,
        data,
      ];

  bool? get isImportant => null;

  String? get message => null;

  DateTime? get timestamp => null;
}
