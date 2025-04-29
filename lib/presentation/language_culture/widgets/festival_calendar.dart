import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/theme.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

class FestivalCalendar extends StatefulWidget {
  final List<Map<String, dynamic>> festivals;
  final Function(Map<String, dynamic>) onFestivalTap;
  final bool showYearRound;
  final DateTime? initialMonth;

  const FestivalCalendar({
    super.key,
    required this.festivals,
    required this.onFestivalTap,
    this.showYearRound = true,
    this.initialMonth,
  });

  @override
  State<FestivalCalendar> createState() => _FestivalCalendarState();
}

class _FestivalCalendarState extends State<FestivalCalendar> {
  late DateTime _selectedMonth;
  List<Map<String, dynamic>> _upcomingFestivals = [];
  List<Map<String, dynamic>> _currentMonthFestivals = [];
  final Map<int, String> _monthNames = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth ?? DateTime.now();
    _processFestivals();
  }

  @override
  void didUpdateWidget(FestivalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.festivals != widget.festivals) {
      _processFestivals();
    }
  }

  void _processFestivals() {
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Process all festivals to normalize dates and find upcoming ones
    List<Map<String, dynamic>> processedFestivals = [];
    
    for (final festival in widget.festivals) {
      final dateStr = festival['date'] as String?;
      
      if (dateStr == null || dateStr.isEmpty) continue;
      
      Map<String, dynamic> processedFestival = Map.from(festival);
      
      try {
        // Handle different date formats
        DateTime? festivalDate;
        
        // Format: "Month Day" (e.g., "April 13-14")
        if (dateStr.contains('-')) {
          // Range date - extract just the start date for sorting
          final startDateStr = dateStr.split('-')[0].trim();
          
          if (startDateStr.contains(' ')) {
            final parts = startDateStr.split(' ');
            if (parts.length == 2) {
              final month = _parseMonth(parts[0]);
              final day = int.tryParse(parts[1]) ?? 1;
              festivalDate = DateTime(currentYear, month, day);
            }
          }
        } 
        // Format: "Month (Full moon)" (e.g., "May (Full moon)")
        else if (dateStr.contains('(')) {
          final monthStr = dateStr.split(' (')[0].trim();
          final month = _parseMonth(monthStr);
          festivalDate = DateTime(currentYear, month, 15); // Approximate full moon
        } 
        // Format: "Month Day" (e.g., "January 14")
        else if (dateStr.contains(' ')) {
          final parts = dateStr.split(' ');
          if (parts.length == 2) {
            final month = _parseMonth(parts[0]);
            final day = int.tryParse(parts[1]) ?? 1;
            festivalDate = DateTime(currentYear, month, day);
          }
        }
        // Format: "Month" (e.g., "December")
        else {
          final month = _parseMonth(dateStr);
          festivalDate = DateTime(currentYear, month, 1);
        }
        
        if (festivalDate != null) {
          // If the festival already happened this year, set it for next year
          if (festivalDate.isBefore(now) && !widget.showYearRound) {
            festivalDate = DateTime(currentYear + 1, festivalDate.month, festivalDate.day);
          }
          
          processedFestival['calculatedDate'] = festivalDate;
          processedFestivals.add(processedFestival);
        }
      } catch (e) {
        // Skip festivals with unparseable dates
        continue;
      }
    }
    
    // Sort festivals by date
    processedFestivals.sort((a, b) {
      final dateA = a['calculatedDate'] as DateTime;
      final dateB = b['calculatedDate'] as DateTime;
      return dateA.compareTo(dateB);
    });
    
    // Get festivals happening in the selected month
    _currentMonthFestivals = processedFestivals.where((festival) {
      final date = festival['calculatedDate'] as DateTime;
      return date.month == _selectedMonth.month;
    }).toList();
    
    // Get upcoming festivals (next 3 months)
    final threeMonthsLater = now.add(const Duration(days: 90));
    _upcomingFestivals = processedFestivals.where((festival) {
      final date = festival['calculatedDate'] as DateTime;
      return date.isAfter(now) && date.isBefore(threeMonthsLater);
    }).take(5).toList();
    
    setState(() {});
  }

  int _parseMonth(String monthName) {
    final normalizedMonth = monthName.toLowerCase().trim();
    
    final monthMap = {
      'january': 1, 'jan': 1,
      'february': 2, 'feb': 2,
      'march': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'may': 5,
      'june': 6, 'jun': 6,
      'july': 7, 'jul': 7,
      'august': 8, 'aug': 8,
      'september': 9, 'sep': 9, 'sept': 9,
      'october': 10, 'oct': 10,
      'november': 11, 'nov': 11,
      'december': 12, 'dec': 12,
    };
    
    return monthMap[normalizedMonth] ?? 1;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      _processFestivals();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      _processFestivals();
    });
  }

  String _getMonthYearString(DateTime date) {
    return '${_monthNames[date.month]!} ${date.year}';
  }

  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    
    // If the event is today
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    
    // If the event is tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    
    // If the event is within the next 7 days
    if (date.difference(now).inDays < 7 && date.isAfter(now)) {
      return timeago.format(date, allowFromNow: true);
    }
    
    // Otherwise use the month and day
    return DateFormat('MMMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month selector
        _buildMonthSelector(),
        
        const SizedBox(height: 16),
        
        // Current month festivals
        if (_currentMonthFestivals.isEmpty)
          _buildEmptyMonthMessage()
        else
          ..._currentMonthFestivals.map(_buildFestivalCard),
          
        const SizedBox(height: 24),
        
        // Upcoming festivals section
        if (_upcomingFestivals.isNotEmpty) ...[
          const Text(
            'Upcoming Festivals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._upcomingFestivals.map(_buildUpcomingFestival),
        ],
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        Text(
          _getMonthYearString(_selectedMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildEmptyMonthMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              FontAwesomeIcons.calendarDay,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No festivals in ${_monthNames[_selectedMonth.month]}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalCard(Map<String, dynamic> festival) {
    final date = festival['calculatedDate'] as DateTime;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => widget.onFestivalTap(festival),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          festival['name'] ?? 'Festival',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          festival['date'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (festival['description'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  festival['description'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingFestival(Map<String, dynamic> festival) {
    final date = festival['calculatedDate'] as DateTime;
    final relativeDate = _getRelativeDateText(date);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          FontAwesomeIcons.calendarDay,
          color: Colors.orange[700],
          size: 18,
        ),
      ),
      title: Text(
        festival['name'] ?? 'Festival',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        relativeDate,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => widget.onFestivalTap(festival),
    );
  }
}