part of 'notification_bloc.dart';

/// Base class for all notification events.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event that is fired when notifications need to be loaded.
class LoadNotifications extends NotificationEvent {
  final String userId;
  
  const LoadNotifications({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

/// Event that is fired when a notification is marked as read.
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;
  final String userId;
  
  const MarkNotificationAsRead({
    required this.notificationId,
    required this.userId,
  });
  
  @override
  List<Object> get props => [notificationId, userId];
}

/// Event that is fired when all notifications are marked as read.
class MarkAllNotificationsAsRead extends NotificationEvent {
  final String userId;
  
  const MarkAllNotificationsAsRead({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

/// Event that is fired when a notification is deleted.
class DeleteNotification extends NotificationEvent {
  final String notificationId;
  final String userId;
  
  const DeleteNotification({
    required this.notificationId,
    required this.userId,
  });
  
  @override
  List<Object> get props => [notificationId, userId];
}

/// Event that is fired when all notifications are cleared.
class ClearAllNotifications extends NotificationEvent {
  final String userId;
  
  const ClearAllNotifications({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

/// Event that is fired when notification settings are updated.
class UpdateNotificationSettings extends NotificationEvent {
  final String userId;
  final Map<String, bool> settings;
  
  const UpdateNotificationSettings({
    required this.userId,
    required this.settings,
  });
  
  @override
  List<Object> get props => [userId, settings];
}