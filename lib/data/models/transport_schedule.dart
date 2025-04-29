import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'transport.dart';

part 'transport_schedule.g.dart';

@JsonSerializable()
class TransportSchedule extends Equatable {
  final String id;
  final String transportId;
  final TransportType transportType;
  final String origin;
  final String destination;
  final String? route;
  final List<ScheduleDay> scheduleDays;
  final List<String>? availableClasses;
  final Map<String, double>? classPrices;
  final Map<String, String>? classFacilities;
  final String? operator;
  final String? operatorContact;
  final String? notes;
  final bool isActive;
  final DateTime lastUpdated;

  const TransportSchedule({
    required this.id,
    required this.transportId,
    required this.transportType,
    required this.origin,
    required this.destination,
    this.route,
    required this.scheduleDays,
    this.availableClasses,
    this.classPrices,
    this.classFacilities,
    this.operator,
    this.operatorContact,
    this.notes,
    this.isActive = true,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        transportId,
        transportType,
        origin,
        destination,
        route,
        scheduleDays,
        availableClasses,
        classPrices,
        classFacilities,
        operator,
        operatorContact,
        notes,
        isActive,
        lastUpdated,
      ];

  /// Creates a copy of this TransportSchedule with the given fields replaced by new values.
  TransportSchedule copyWith({
    String? id,
    String? transportId,
    TransportType? transportType,
    String? origin,
    String? destination,
    String? route,
    List<ScheduleDay>? scheduleDays,
    List<String>? availableClasses,
    Map<String, double>? classPrices,
    Map<String, String>? classFacilities,
    String? operator,
    String? operatorContact,
    String? notes,
    bool? isActive,
    DateTime? lastUpdated,
  }) {
    return TransportSchedule(
      id: id ?? this.id,
      transportId: transportId ?? this.transportId,
      transportType: transportType ?? this.transportType,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      route: route ?? this.route,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      availableClasses: availableClasses ?? this.availableClasses,
      classPrices: classPrices ?? this.classPrices,
      classFacilities: classFacilities ?? this.classFacilities,
      operator: operator ?? this.operator,
      operatorContact: operatorContact ?? this.operatorContact,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Creates a TransportSchedule from a JSON object.
  factory TransportSchedule.fromJson(Map<String, dynamic> json) => _$TransportScheduleFromJson(json);

  /// Converts this TransportSchedule to a JSON object.
  Map<String, dynamic> toJson() => _$TransportScheduleToJson(this);

  /// Returns all departure times for a specified day of the week.
  List<ScheduleTime> getDepartureTimesForDay(int weekday) {
    final day = scheduleDays.firstWhere(
      (day) => day.weekday == weekday,
      orElse: () => ScheduleDay(weekday: weekday, scheduleTimes: const []),
    );
    return day.scheduleTimes;
  }

  /// Returns the next available departure time from now.
  ScheduleTime? getNextDepartureTime() {
    final now = DateTime.now();
    final today = now.weekday;
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Check today's schedule first
    final todaySchedule = getDepartureTimesForDay(today);
    final todayRemainingSchedules = todaySchedule.where(
      (time) => time.departureTime.compareTo(currentTime) > 0,
    ).toList();

    if (todayRemainingSchedules.isNotEmpty) {
      // Sort by departure time
      todayRemainingSchedules.sort(
        (a, b) => a.departureTime.compareTo(b.departureTime),
      );
      return todayRemainingSchedules.first;
    }

    // If no more departures today, check the next 7 days
    for (int i = 1; i <= 7; i++) {
      final nextDay = (today + i) % 7;
      final nextDaySchedule = getDepartureTimesForDay(nextDay == 0 ? 7 : nextDay);
      
      if (nextDaySchedule.isNotEmpty) {
        // Sort by departure time
        nextDaySchedule.sort(
          (a, b) => a.departureTime.compareTo(b.departureTime),
        );
        return nextDaySchedule.first;
      }
    }

    return null; // No upcoming departures found
  }

  /// Returns all departure times for the next 7 days.
  List<ScheduleDeparture> getUpcomingDepartures({int limit = 10}) {
    final now = DateTime.now();
    final today = now.weekday;
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    List<ScheduleDeparture> upcoming = [];

    // Check today's schedule first
    final todaySchedule = getDepartureTimesForDay(today);
    final todayRemainingSchedules = todaySchedule.where(
      (time) => time.departureTime.compareTo(currentTime) > 0,
    ).toList();

    for (var time in todayRemainingSchedules) {
      upcoming.add(ScheduleDeparture(
        weekday: today,
        scheduleTime: time,
        date: DateTime(now.year, now.month, now.day),
      ));
    }

    // Check the next 6 days
    for (int i = 1; i <= 6; i++) {
      final nextDay = (today + i) % 7;
      final weekday = nextDay == 0 ? 7 : nextDay;
      final nextDaySchedule = getDepartureTimesForDay(weekday);
      
      final nextDate = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      
      for (var time in nextDaySchedule) {
        upcoming.add(ScheduleDeparture(
          weekday: weekday,
          scheduleTime: time,
          date: nextDate,
        ));
      }
    }

    // Sort by date and time
    upcoming.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return a.scheduleTime.departureTime.compareTo(b.scheduleTime.departureTime);
    });

    // Return only the requested number of departures
    return upcoming.take(limit).toList();
  }

  /// Returns the estimated travel time in minutes.
  int getEstimatedTravelTimeMinutes() {
    if (scheduleDays.isEmpty || scheduleDays.first.scheduleTimes.isEmpty) {
      return 0;
    }

    // Use the first scheduled time as reference
    final firstSchedule = scheduleDays.first.scheduleTimes.first;
    
    // Parse departure and arrival times
    final departure = _parseTimeString(firstSchedule.departureTime);
    final arrival = _parseTimeString(firstSchedule.arrivalTime ?? '');
    
    if (departure == null || arrival == null) {
      return 0;
    }
    
    // Calculate time difference in minutes
    int minutes = (arrival.hour * 60 + arrival.minute) - (departure.hour * 60 + departure.minute);
    
    // Handle overnight trips
    if (minutes < 0) {
      minutes += 24 * 60; // Add a full day
    }
    
    return minutes;
  }

  /// Helper method to parse time strings like "14:30"
  TimeOfDay? _parseTimeString(String timeStr) {
    if (timeStr.isEmpty) return null;
    
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    
    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Invalid format
    }
    
    return null;
  }

  /// Returns the price for a specific class or the default price.
  double getPriceForClass(String className) {
    if (classPrices == null || !classPrices!.containsKey(className)) {
      // Return default price if specified class is not found
      return classPrices?.containsKey('default') == true
          ? classPrices!['default']!
          : 0.0;
    }
    return classPrices![className]!;
  }

  /// Checks if this schedule is available on a specific date.
  bool isAvailableOnDate(DateTime date) {
    final weekday = date.weekday;
    return scheduleDays.any((day) => day.weekday == weekday && day.scheduleTimes.isNotEmpty);
  }
}

@JsonSerializable()
class ScheduleDay extends Equatable {
  final int weekday; // 1-7 (Monday to Sunday)
  final List<ScheduleTime> scheduleTimes;

  const ScheduleDay({
    required this.weekday,
    required this.scheduleTimes,
  });

  @override
  List<Object?> get props => [weekday, scheduleTimes];

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => _$ScheduleDayFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleDayToJson(this);
}

@JsonSerializable()
class ScheduleTime extends Equatable {
  final String departureTime; // Format: HH:MM (24-hour)
  final String? arrivalTime; // Format: HH:MM (24-hour)
  final List<String>? availableClasses;
  final Map<String, int>? availableSeats;
  final String? platformInfo;
  final bool isExpress;
  final List<String>? intermediateStops;
  final String? specialNotes;

  const ScheduleTime({
    required this.departureTime,
    this.arrivalTime,
    this.availableClasses,
    this.availableSeats,
    this.platformInfo,
    this.isExpress = false,
    this.intermediateStops,
    this.specialNotes,
  });

  @override
  List<Object?> get props => [
        departureTime,
        arrivalTime,
        availableClasses,
        availableSeats,
        platformInfo,
        isExpress,
        intermediateStops,
        specialNotes,
      ];

  factory ScheduleTime.fromJson(Map<String, dynamic> json) => _$ScheduleTimeFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleTimeToJson(this);

  /// Get a formatted duration string between departure and arrival
  String getDurationString() {
    if (arrivalTime == null) return 'Unknown';
    
    final departure = _parseTimeString(departureTime);
    final arrival = _parseTimeString(arrivalTime!);
    
    if (departure == null || arrival == null) {
      return 'Unknown';
    }
    
    // Calculate minutes
    int departureMinutes = departure.hour * 60 + departure.minute;
    int arrivalMinutes = arrival.hour * 60 + arrival.minute;
    
    // Handle overnight trips
    if (arrivalMinutes < departureMinutes) {
      arrivalMinutes += 24 * 60; // Add a full day
    }
    
    int durationMinutes = arrivalMinutes - departureMinutes;
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Helper method to parse time strings like "14:30"
  TimeOfDay? _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    
    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Invalid format
    }
    
    return null;
  }

  /// Check if there are available seats for a specific class
  bool hasAvailableSeats(String className) {
    if (availableSeats == null || !availableSeats!.containsKey(className)) {
      return true; // Assume available if not specified
    }
    return availableSeats![className]! > 0;
  }

  /// Get the number of available seats for a specific class
  int getAvailableSeatsForClass(String className) {
    if (availableSeats == null || !availableSeats!.containsKey(className)) {
      return 0;
    }
    return availableSeats![className]!;
  }
}

/// Helper class for representing upcoming departures with dates
class ScheduleDeparture {
  final int weekday;
  final ScheduleTime scheduleTime;
  final DateTime date;

  ScheduleDeparture({
    required this.weekday,
    required this.scheduleTime,
    required this.date,
  });

  /// Returns the full departure datetime
  DateTime getDepartureDateTime() {
    final timeparts = scheduleTime.departureTime.split(':');
    final hour = int.parse(timeparts[0]);
    final minute = int.parse(timeparts[1]);
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  /// Returns a formatted string representing the departure date and time
  String getFormattedDeparture(String format) {
    final departure = getDepartureDateTime();
    
    // You would typically use intl package for proper formatting
    // This is a simple implementation
    if (format == 'time') {
      return '${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
    } else if (format == 'date') {
      return '${departure.day}/${departure.month}/${departure.year}';
    } else {
      return '${departure.day}/${departure.month}/${departure.year} ${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Returns a relative day string (Today, Tomorrow, or weekday name)
  String getRelativeDayString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final departureDate = DateTime(date.year, date.month, date.day);
    
    final difference = departureDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      switch (weekday) {
        case 1: return 'Monday';
        case 2: return 'Tuesday';
        case 3: return 'Wednesday';
        case 4: return 'Thursday';
        case 5: return 'Friday';
        case 6: return 'Saturday';
        case 7: return 'Sunday';
        default: return '';
      }
    }
  }
}