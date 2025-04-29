// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actionLink: json['actionLink'] as String?,
      actionText: json['actionText'] as String?,
      imageUrl: json['imageUrl'] as String?,
      referenceId: json['referenceId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'actionLink': instance.actionLink,
      'actionText': instance.actionText,
      'imageUrl': instance.imageUrl,
      'referenceId': instance.referenceId,
      'data': instance.data,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.booking: 'booking',
  NotificationType.deals: 'deals',
  NotificationType.reminder: 'reminder',
  NotificationType.system: 'system',
  NotificationType.itinerary: 'itinerary',
  NotificationType.social: 'social',
  NotificationType.weather: 'weather',
  NotificationType.travel: 'travel',
  NotificationType.general: 'general',
  NotificationType.success: 'success',
  NotificationType.error: 'error',
  NotificationType.warning: 'warning',
  NotificationType.info: 'info',
  NotificationType.bookingConfirmed: 'bookingConfirmed',
  NotificationType.tripReminder: 'tripReminder',
  NotificationType.dealAlert: 'dealAlert',
  NotificationType.alert: 'alert',
  NotificationType.destination: 'destination',
};
