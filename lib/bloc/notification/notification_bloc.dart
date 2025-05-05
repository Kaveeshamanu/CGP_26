import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/data/models/notification.dart';
import 'package:taprobana_trails/data/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// BLoC for managing notification data.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  /// Creates a new instance of [NotificationBloc].
  NotificationBloc({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationsLoading());

      final notifications = await _notificationRepository.getNotifications(
        userId: event.userId,
      );

      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      emit(NotificationError(message: 'Failed to load notifications'));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markNotificationAsRead(
        notificationId: event.notificationId,
      );

      // Reload notifications to get updated state
      final notifications = await _notificationRepository.getNotifications(
        userId: event.userId,
      );

      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      emit(NotificationError(message: 'Failed to mark notification as read'));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationActionLoading());

      await _notificationRepository.markAllNotificationsAsRead(
        userId: event.userId,
      );

      // Reload notifications to get updated state
      final notifications = await _notificationRepository.getNotifications(
        userId: event.userId,
      );

      emit(NotificationActionSuccess());
      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      emit(NotificationError(
          message: 'Failed to mark all notifications as read'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteNotification(
        event.notificationId,
      );

      // Reload notifications to get updated state
      final notifications = await _notificationRepository.getNotifications(
        userId: event.userId,
      );

      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      emit(NotificationError(message: 'Failed to delete notification'));
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationActionLoading());

      await _notificationRepository.clearAllNotifications(
        userId: event.userId,
      );

      emit(NotificationActionSuccess());
      emit(NotificationsLoaded(notifications: []));
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
      emit(NotificationError(message: 'Failed to clear all notifications'));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationActionLoading());

      await _notificationRepository.updateNotificationSettings(
        userId: event.userId,
        settings: event.settings,
      );

      emit(NotificationActionSuccess());
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      emit(
          NotificationError(message: 'Failed to update notification settings'));
    }
  }
}
