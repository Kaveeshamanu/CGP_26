import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../data/models/itinerary.dart';
import '../../../bloc/itinerary/itinerary_bloc.dart';
import '../../../bloc/itinerary/itinerary_event.dart';
import '../../../bloc/itinerary/itinerary_state.dart';
import '../../../config/theme.dart';
import '../../common/widgets/loaders.dart';
import '../widgets/activity_card.dart';

class CalendarView extends StatefulWidget {
  final String? destinationId;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime)? onDaySelected;

  const CalendarView({
    super.key,
    this.destinationId,
    this.startDate,
    this.endDate,
    this.onDaySelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late CalendarFormat _calendarFormat;
  
  Map<DateTime, List<Activity>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.startDate ?? DateTime.now();
    _focusedDay = _selectedDay;
    _firstDay = widget.startDate ?? DateTime.now().subtract(const Duration(days: 30));
    _lastDay = widget.endDate ?? DateTime.now().add(const Duration(days: 365));
    _calendarFormat = CalendarFormat.month;
    
    // Load itinerary data
    if (widget.destinationId != null) {
      context.read<ItineraryBloc>().add(LoadItineraryEvent(destinationId: widget.destinationId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItineraryBloc, ItineraryState>(
      listener: (context, state) {
        if (state is ItineraryLoadedState) {
          _updateEvents(state.itinerary);
        }
      },
      builder: (context, state) {
        if (state is ItineraryLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: 16),
            _buildSelectedDayActivities(),
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      child: TableCalendar<Activity>(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            if (widget.onDaySelected != null) {
              widget.onDaySelected!(selectedDay);
            }
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: TextStyle(color: AppTheme.primaryColor),
          titleTextStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();
            return Positioned(
              bottom: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                ),
                width: 6,
                height: 6,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayActivities() {
    final activities = _getEventsForDay(_selectedDay);
    
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'No activities planned for ${DateFormat('MMM d, yyyy').format(_selectedDay)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to add activity screen with selected date
                  // Navigator.of(context).push(...);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppTheme.primaryColor,
                    onPressed: () {
                      // Navigate to add activity screen with selected date
                      // Navigator.of(context).push(...);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActivityCard(
                      activity: activity,
                      onTap: () {
                        // Navigate to activity details
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Activity> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _updateEvents(Itinerary itinerary) {
    final events = <DateTime, List<Activity>>{};
    
    for (final activity in itinerary.activities) {
      final activityDate = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      
      if (events[activityDate] == null) {
        events[activityDate] = [];
      }
      
      events[activityDate]!.add(activity);
    }
    
    // Sort activities by time for each day
    events.forEach((date, activities) {
      activities.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    
    setState(() {
      _events = events;
    });
  }
  
  ActivityCard({required Activity activity, required Null Function() onTap}) {}
}

class ItineraryLoadingState {
}

class Activity {
  get category => null;

  get imageUrl => null;

  get notes => null;
}

extension on Object {
  get startTime => null;
}