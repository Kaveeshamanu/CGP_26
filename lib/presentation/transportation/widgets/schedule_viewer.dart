import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../config/theme.dart';
import '../../../data/models/transport.dart';
import '../../../data/models/transport_schedule.dart';

class ScheduleViewer extends StatefulWidget {
  final TransportSchedule schedule;
  final Function(ScheduleDeparture)? onDepartureSelected;
  final DateTime? selectedDate;
  final bool showFilters;
  final bool highlightNextDeparture;

  const ScheduleViewer({
    super.key,
    required this.schedule,
    this.onDepartureSelected,
    this.selectedDate,
    this.showFilters = true,
    this.highlightNextDeparture = true,
  });

  @override
  State<ScheduleViewer> createState() => _ScheduleViewerState();
}

class _ScheduleViewerState extends State<ScheduleViewer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedClass;
  bool _showExpressOnly = false;
  bool _hasAvailableSeatsOnly = false;
  
  // List of all departure times for the week
  List<ScheduleDeparture> _upcomingDepartures = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize selected date if provided
    if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
    }
    
    // Initialize tab controller for the 7 days of the week
    _tabController = TabController(length: 7, vsync: this);
    
    // Set initial tab to the current day of week (0 = Monday, 6 = Sunday)
    int today = _selectedDate.weekday - 1;
    _tabController.index = today;
    
    // Initialize available classes if any
    if (widget.schedule.availableClasses != null && 
        widget.schedule.availableClasses!.isNotEmpty) {
      _selectedClass = widget.schedule.availableClasses!.first;
    }
    
    // Load departures
    _loadDepartures();
  }

  @override
  void didUpdateWidget(ScheduleViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.schedule.id != widget.schedule.id ||
        oldWidget.selectedDate != widget.selectedDate) {
      if (widget.selectedDate != null) {
        _selectedDate = widget.selectedDate!;
        _tabController.index = _selectedDate.weekday - 1;
      }
      
      _loadDepartures();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDepartures() {
    // Get upcoming departures for the next 7 days
    _upcomingDepartures = widget.schedule.getUpcomingDepartures(limit: 100);
    
    setState(() {});
  }

  void _onDaySelected(int index) {
    // Update selected date based on tab index
    final now = DateTime.now();
    final selectedWeekday = index + 1; // 1 = Monday, 7 = Sunday
    
    // Calculate the date for the selected weekday
    int daysToAdd = selectedWeekday - now.weekday;
    if (daysToAdd < 0) {
      daysToAdd += 7; // Add a week if we're going to a previous day
    }
    
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day + daysToAdd);
    });
  }

  void _onClassSelected(String? className) {
    setState(() {
      _selectedClass = className;
    });
  }

  void _toggleExpressOnly(bool? value) {
    setState(() {
      _showExpressOnly = value ?? false;
    });
  }

  void _toggleAvailableSeatsOnly(bool? value) {
    setState(() {
      _hasAvailableSeatsOnly = value ?? false;
    });
  }

  List<ScheduleDeparture> _getFilteredDepartures() {
    // Get departures for the selected day
    return _upcomingDepartures.where((departure) {
      // Check if it's the selected date
      final departureDate = departure.date;
      if (departureDate.year != _selectedDate.year ||
          departureDate.month != _selectedDate.month ||
          departureDate.day != _selectedDate.day) {
        return false;
      }
      
      // Filter by express
      if (_showExpressOnly && !departure.scheduleTime.isExpress) {
        return false;
      }
      
      // Filter by class availability
      if (_selectedClass != null && 
          departure.scheduleTime.availableClasses != null &&
          !departure.scheduleTime.availableClasses!.contains(_selectedClass)) {
        return false;
      }
      
      // Filter by seat availability
      if (_hasAvailableSeatsOnly && 
          _selectedClass != null &&
          !departure.scheduleTime.hasAvailableSeats(_selectedClass!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get today's index for highlighting
    final today = DateTime.now().weekday - 1;
    
    return Column(
      children: [
        // Day tabs
        SizedBox(
          height: 60,
          child: TabBar(
            controller: _tabController,
            onTap: _onDaySelected,
            isScrollable: true,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 3.0,
                ),
              ),
            ),
            tabs: [
              _buildDayTab('Mon', 0, today),
              _buildDayTab('Tue', 1, today),
              _buildDayTab('Wed', 2, today),
              _buildDayTab('Thu', 3, today),
              _buildDayTab('Fri', 4, today),
              _buildDayTab('Sat', 5, today),
              _buildDayTab('Sun', 6, today),
            ],
          ),
        ),
        
        // Filters
        if (widget.showFilters) _buildFilters(),
        
        // Schedule content
        Expanded(
          child: _buildScheduleList(),
        ),
      ],
    );
  }

  Widget _buildDayTab(String dayName, int index, int today) {
    final isToday = index == today;
    
    // Calculate the date for this tab
    final now = DateTime.now();
    final weekday = index + 1;
    int daysToAdd = weekday - now.weekday;
    if (daysToAdd < 0) daysToAdd += 7;
    final tabDate = DateTime(now.year, now.month, now.day + daysToAdd);
    
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${tabDate.day}/${tabDate.month}',
            style: TextStyle(
              fontSize: 12,
              color: isToday ? AppTheme.primaryColor : Colors.grey[600],
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class selection
          if (widget.schedule.availableClasses != null && 
              widget.schedule.availableClasses!.isNotEmpty) ...[
            const Text(
              'Class:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final className in widget.schedule.availableClasses!)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(className),
                        selected: _selectedClass == className,
                        onSelected: (selected) {
                          if (selected) {
                            _onClassSelected(className);
                          }
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedClass == className
                              ? AppTheme.primaryColor
                              : Colors.black87,
                          fontWeight: _selectedClass == className
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Express and Availability filters
          Row(
            children: [
              // Express only
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _showExpressOnly,
                      onChanged: _toggleExpressOnly,
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Text(
                      'Express Only',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              // Available seats only
              if (_selectedClass != null)
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _hasAvailableSeatsOnly,
                        onChanged: _toggleAvailableSeatsOnly,
                        activeColor: AppTheme.primaryColor,
                      ),
                      const Flexible(
                        child: Text(
                          'Available Seats Only',
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final filteredDepartures = _getFilteredDepartures();
    
    if (filteredDepartures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No departures available for the selected filters',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Sort by departure time
    filteredDepartures.sort((a, b) {
      return a.scheduleTime.departureTime.compareTo(b.scheduleTime.departureTime);
    });
    
    // Find the next departure
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final isToday = _selectedDate.year == todayDate.year && 
                    _selectedDate.month == todayDate.month && 
                    _selectedDate.day == todayDate.day;
    
    ScheduleDeparture? nextDeparture;
    if (isToday && widget.highlightNextDeparture) {
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      nextDeparture = filteredDepartures.firstWhereOrNull(
        (dep) => dep.scheduleTime.departureTime.compareTo(currentTime) > 0
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDepartures.length,
      itemBuilder: (context, index) {
        final departure = filteredDepartures[index];
        final isNextDeparture = nextDeparture != null && 
                               departure.scheduleTime.departureTime == nextDeparture.scheduleTime.departureTime;
        
        return _buildDepartureCard(departure, isNextDeparture);
      },
    );
  }

  Widget _buildDepartureCard(ScheduleDeparture departure, bool isNextDeparture) {
    final scheduleTime = departure.scheduleTime;
    
    // Format departure time
    final departureTimeParts = scheduleTime.departureTime.split(':');
    final departureHour = int.parse(departureTimeParts[0]);
    final departureMinute = int.parse(departureTimeParts[1]);
    final departurePeriod = departureHour >= 12 ? 'PM' : 'AM';
    final formattedHour = departureHour > 12 ? departureHour - 12 : departureHour;
    final displayTime = '$formattedHour:${departureMinute.toString().padLeft(2, '0')} $departurePeriod';
    
    // Format arrival time if available
    String arrivalTime = '';
    if (scheduleTime.arrivalTime != null) {
      final arrivalTimeParts = scheduleTime.arrivalTime!.split(':');
      final arrivalHour = int.parse(arrivalTimeParts[0]);
      final arrivalMinute = int.parse(arrivalTimeParts[1]);
      final arrivalPeriod = arrivalHour >= 12 ? 'PM' : 'AM';
      final formattedArrivalHour = arrivalHour > 12 ? arrivalHour - 12 : arrivalHour;
      arrivalTime = '$formattedArrivalHour:${arrivalMinute.toString().padLeft(2, '0')} $arrivalPeriod';
    }
    
    return Card(
      elevation: isNextDeparture ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isNextDeparture
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (widget.onDepartureSelected != null) {
            widget.onDepartureSelected!(departure);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time and express indicator
              Row(
                children: [
                  // Departure time
                  Text(
                    displayTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (scheduleTime.isExpress) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Express',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Arrival time
                  if (arrivalTime.isNotEmpty) ...[
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      arrivalTime,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Route info
              if (widget.schedule.route != null) ...[
                Text(
                  widget.schedule.route!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Duration and platforms
              Row(
                children: [
                  // Duration
                  if (scheduleTime.arrivalTime != null) ...[
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scheduleTime.getDurationString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // Platform info
                  if (scheduleTime.platformInfo != null) ...[
                    const Icon(
                      Icons.exit_to_app,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scheduleTime.platformInfo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Available seats indicator
                  if (_selectedClass != null &&
                      scheduleTime.availableSeats != null &&
                      scheduleTime.availableSeats!.containsKey(_selectedClass)) ...[
                    const Icon(
                      Icons.event_seat,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${scheduleTime.availableSeats![_selectedClass]} seats',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              
              // Intermediate stops
              if (scheduleTime.intermediateStops != null &&
                  scheduleTime.intermediateStops!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.stop_circle_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Stops: ${scheduleTime.intermediateStops!.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Special notes
              if (scheduleTime.specialNotes != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scheduleTime.specialNotes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Next departure indicator
              if (isNextDeparture) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Next Departure',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Price & book button
              if (_selectedClass != null && 
                  widget.schedule.classPrices != null &&
                  widget.schedule.classPrices!.containsKey(_selectedClass)) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      'Rs. ${widget.schedule.classPrices![_selectedClass]!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Book button
                    OutlinedButton(
                      onPressed: () {
                        if (widget.onDepartureSelected != null) {
                          widget.onDepartureSelected!(departure);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}