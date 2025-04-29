part of 'notification_bloc.dart';

/// Base class for all notification states.
abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state of the notification bloc.
class NotificationInitial extends NotificationState {}

/// State when notifications are being loaded.
class NotificationsLoading extends NotificationState {}

/// State when notifications have been successfully loaded.
class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;
  
  const NotificationsLoaded({required this.notifications});
  
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  
  @override
  List<Object> get props => [notifications];
}

/// State when a notification action is being processed.
class NotificationActionLoading extends NotificationState {}

/// State when a notification action has been successfully processed.
class NotificationActionSuccess extends NotificationState {}

/// State when there is an error in notification operations.
class NotificationError extends NotificationState {
  final String message;
  
  const NotificationError({required this.message});
  
  @override
  List<Object> get props => [message];
}