import 'package:intl/intl.dart';

/// Utility class for date and time operations.
class DateTimeUtils {
  // Private constructor to prevent instantiation
  DateTimeUtils._();

  /// Date format constants for common formats
  static final _dateFormatter = DateFormat('yyyy-MM-dd');
  static final _dateFormatterDots = DateFormat('dd.MM.yyyy');
  static final _dateFormatterSlashes = DateFormat('dd/MM/yyyy');
  static final _dateFormatterMonthYear = DateFormat('MMMM yyyy');
  static final _dateFormatterReadable = DateFormat('d MMM yyyy');
  static final _dateFormatterFull = DateFormat('EEEE, d MMMM yyyy');
  static final _timeFormatter24h = DateFormat('HH:mm');
  static final _timeFormatter12h = DateFormat('h:mm a');
  static final _dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
  static final _dateTimeFormatterReadable = DateFormat('d MMM yyyy, HH:mm');
  static final _dateTimeFormatter12h = DateFormat('d MMM yyyy, h:mm a');
  
  /// Formats a DateTime to yyyy-MM-dd format.
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }
  
  /// Formats a DateTime to dd.MM.yyyy format.
  static String formatDateWithDots(DateTime date) {
    return _dateFormatterDots.format(date);
  }
  
  /// Formats a DateTime to dd/MM/yyyy format.
  static String formatDateWithSlashes(DateTime date) {
    return _dateFormatterSlashes.format(date);
  }
  
  /// Formats a DateTime to "Month Year" format (e.g., "January 2025").
  static String formatMonthYear(DateTime date) {
    return _dateFormatterMonthYear.format(date);
  }
  
  /// Formats a DateTime to a readable date format (e.g., "12 Jan 2025").
  static String formatReadableDate(DateTime date) {
    return _dateFormatterReadable.format(date);
  }
  
  /// Formats a DateTime to a full date format (e.g., "Sunday, 12 January 2025").
  static String formatFullDate(DateTime date) {
    return _dateFormatterFull.format(date);
  }
  
  /// Formats a DateTime to 24-hour time format (e.g., "14:30").
  static String formatTime24h(DateTime date) {
    return _timeFormatter24h.format(date);
  }
  
  /// Formats a DateTime to 12-hour time format (e.g., "2:30 PM").
  static String formatTime12h(DateTime date) {
    return _timeFormatter12h.format(date);
  }
  
  /// Formats a DateTime to a datetime format (e.g., "2025-01-12 14:30").
  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }
  
  /// Formats a DateTime to a readable datetime format (e.g., "12 Jan 2025, 14:30").
  static String formatReadableDateTime(DateTime date) {
    return _dateTimeFormatterReadable.format(date);
  }
  
  /// Formats a DateTime to a readable 12-hour datetime format (e.g., "12 Jan 2025, 2:30 PM").
  static String formatReadableDateTime12h(DateTime date) {
    return _dateTimeFormatter12h.format(date);
  }
  
  /// Parses a date string in yyyy-MM-dd format.
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Parses a date string in a flexible format.
  static DateTime? parseFlexibleDate(String dateString) {
    // Try different common formats
    final formats = [
      'yyyy-MM-dd',
      'dd.MM.yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'd MMM yyyy',
      'MMMM d, yyyy',
    ];
    
    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (_) {
        // Try next format
      }
    }
    
    return null;
  }
  
  /// Gets the current date with time set to midnight.
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Gets tomorrow's date with time set to midnight.
  static DateTime tomorrow() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day + 1);
  }
  
  /// Gets yesterday's date with time set to midnight.
  static DateTime yesterday() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day - 1);
  }
  
  /// Checks if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// Checks if a date is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  /// Checks if a date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  /// Checks if a date is in the past.
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }
  
  /// Checks if a date is in the future.
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }
  
  /// Gets the number of days between two dates.
  static int daysBetween(DateTime from, DateTime to) {
    // Normalize time to midnight to count only days
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  /// Gets the number of hours between two DateTimes.
  static int hoursBetween(DateTime from, DateTime to) {
    return to.difference(from).inHours;
  }
  
  /// Gets the number of minutes between two DateTimes.
  static int minutesBetween(DateTime from, DateTime to) {
    return to.difference(from).inMinutes;
  }
  
  /// Adds days to a date.
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }
  
  /// Subtracts days from a date.
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }
  
  /// Gets the first day of the month for a given date.
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Gets the last day of the month for a given date.
  static DateTime lastDayOfMonth(DateTime date) {
    // Going to the first day of the next month, then subtracting one day
    return DateTime(date.year, date.month + 1, 1).subtract(const Duration(days: 1));
  }
  
  /// Gets the first day of the week for a given date.
  /// The week starts on Monday.
  static DateTime firstDayOfWeek(DateTime date) {
    // Map weekday to start from Monday (1) to Sunday (7)
    final weekday = date.weekday;
    // Subtract the days to get to Monday
    return date.subtract(Duration(days: weekday - 1));
  }
  
  /// Gets the last day of the week for a given date.
  /// The week ends on Sunday.
  static DateTime lastDayOfWeek(DateTime date) {
    // Map weekday to start from Monday (1) to Sunday (7)
    final weekday = date.weekday;
    // Add the days to get to Sunday
    return date.add(Duration(days: 7 - weekday));
  }
  
  /// Gets a list of dates for a date range.
  static List<DateTime> getDateRange(DateTime startDate, DateTime endDate) {
    final dates = <DateTime>[];
    
    // Normalize time to midnight
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    for (var i = 0; i <= daysBetween(start, end); i++) {
      dates.add(start.add(Duration(days: i)));
    }
    
    return dates;
  }
  
  /// Gets a list of month dates for a date range.
  /// Returns the first day of each month in the range.
  static List<DateTime> getMonthRange(DateTime startDate, DateTime endDate) {
    final months = <DateTime>[];
    
    // Normalize to first day of month
    var currentMonth = DateTime(startDate.year, startDate.month, 1);
    final lastMonth = DateTime(endDate.year, endDate.month, 1);
    
    while (!currentMonth.isAfter(lastMonth)) {
      months.add(currentMonth);
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }
    
    return months;
  }
  
  /// Gets a list of dates for a week.
  static List<DateTime> getWeekDates(DateTime date) {
    final firstDay = firstDayOfWeek(date);
    return getDateRange(firstDay, firstDay.add(const Duration(days: 6)));
  }
  
  /// Gets a list of dates for a month.
  static List<DateTime> getMonthDates(DateTime date) {
    final firstDay = firstDayOfMonth(date);
    final lastDay = lastDayOfMonth(date);
    return getDateRange(firstDay, lastDay);
  }
  
  /// Gets the age in years from a birthdate.
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    
    int age = now.year - birthDate.year;
    // Adjust age if birth date hasn't occurred this year yet
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  /// Gets a relative time string.
  /// For example: "just now", "10 minutes ago", "yesterday", etc.
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) {
        return 'yesterday';
      }
      return '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  
  /// Gets a relative date string for a future date.
  /// For example: "in 5 minutes", "tomorrow", "in 3 days", etc.
  static String getRelativeFutureTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inSeconds < 60) {
      return 'in a moment';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'in $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) {
        return 'tomorrow';
      }
      return 'in $days days';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'in $years ${years == 1 ? 'year' : 'years'}';
    }
  }
  
  /// Gets a formatted duration string.
  /// For example: "3h 15m", "45m", "1d 5h", etc.
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    final parts = <String>[];
    
    if (days > 0) {
      parts.add('${days}d');
    }
    
    if (hours > 0) {
      parts.add('${hours}h');
    }
    
    if (minutes > 0 || parts.isEmpty) {
      parts.add('${minutes}m');
    }
    
    return parts.join(' ');
  }
  
  /// Gets a human-readable duration string.
  static String formatDurationWords(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    final parts = <String>[];
    
    if (days > 0) {
      parts.add('$days ${days == 1 ? 'day' : 'days'}');
    }
    
    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    }
    
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    }
    
    return parts.join(', ');
  }
  
  /// Checks if two date ranges overlap.
  static bool doDateRangesOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    // Ensure start is before end for both ranges
    if (start1.isAfter(end1)) {
      final temp = start1;
      start1 = end1;
      end1 = temp;
    }
    
    if (start2.isAfter(end2)) {
      final temp = start2;
      start2 = end2;
      end2 = temp;
    }
    
    // Check for overlap
    return start1.isBefore(end2) && end1.isAfter(start2);
  }
  
  /// Gets the duration between two times on the same day.
  static Duration timeBetween(DateTime time1, DateTime time2) {
    // Normalize the dates to just compare times
    final normalized1 = DateTime(
      2000, 1, 1, 
      time1.hour, time1.minute, time1.second,
    );
    
    final normalized2 = DateTime(
      2000, 1, 1, 
      time2.hour, time2.minute, time2.second,
    );
    
    return normalized2.difference(normalized1);
  }
  
  /// Gets the weekday name from a DateTime.
  static String getWeekdayName(DateTime date, {bool short = false}) {
    if (short) {
      // Short weekday name (e.g., "Mon")
      return DateFormat('E').format(date);
    } else {
      // Full weekday name (e.g., "Monday")
      return DateFormat('EEEE').format(date);
    }
  }
  
  /// Gets the month name from a DateTime.
  static String getMonthName(DateTime date, {bool short = false}) {
    if (short) {
      // Short month name (e.g., "Jan")
      return DateFormat('MMM').format(date);
    } else {
      // Full month name (e.g., "January")
      return DateFormat('MMMM').format(date);
    }
  }
  
  /// Formats a time span (e.g., "10:00 - 11:30").
  static String formatTimeSpan(DateTime start, DateTime end, {bool use24Hour = true}) {
    final formatter = use24Hour ? _timeFormatter24h : _timeFormatter12h;
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
  
  /// Formats a date span (e.g., "12 Jan - 15 Jan 2025").
  static String formatDateSpan(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      // Same month and year
      return '${start.day} - ${end.day} ${getMonthName(start, short: true)} ${start.year}';
    } else if (start.year == end.year) {
      // Same year
      return '${start.day} ${getMonthName(start, short: true)} - ${end.day} ${getMonthName(end, short: true)} ${start.year}';
    } else {
      // Different years
      return '${start.day} ${getMonthName(start, short: true)} ${start.year} - ${end.day} ${getMonthName(end, short: true)} ${end.year}';
    }
  }
  
  /// Checks if a date is a weekend (Saturday or Sunday).
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }
  
  /// Checks if a date is a weekday (Monday to Friday).
  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }
  
  /// Gets the current time zone offset as a string (e.g., "+05:30").
  static String getTimeZoneOffset() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    
    final sign = offset.isNegative ? '-' : '+';
    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    
    return '$sign$hoursStr:$minutesStr';
  }
  
  /// Gets the current time zone name.
  static String getTimeZoneName() {
    final now = DateTime.now();
    return now.timeZoneName;
  }
  
  /// Gets a date with no time component.
  static DateTime removeTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  
  /// Converts a UTC DateTime to local time.
  static DateTime utcToLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }
  
  /// Converts a local DateTime to UTC.
  static DateTime localToUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }
  
  /// Gets the next occurrence of a given weekday.
  static DateTime nextWeekday(int weekday) {
    final now = DateTime.now();
    final daysUntilNextWeekday = (weekday - now.weekday) % 7;
    // If today is the target weekday, get next week's occurrence
    final daysToAdd = daysUntilNextWeekday == 0 ? 7 : daysUntilNextWeekday;
    return now.add(Duration(days: daysToAdd));
  }
  
  /// Gets the previous occurrence of a given weekday.
  static DateTime previousWeekday(int weekday) {
    final now = DateTime.now();
    final daysUntilPrevWeekday = (now.weekday - weekday) % 7;
    // If today is the target weekday, get previous week's occurrence
    final daysToSubtract = daysUntilPrevWeekday == 0 ? 7 : daysUntilPrevWeekday;
    return now.subtract(Duration(days: daysToSubtract));
  }
  
  /// Gets the quarter of the year (1-4) for a given date.
  static int getQuarter(DateTime date) {
    return ((date.month - 1) / 3).floor() + 1;
  }
  
  /// Gets the number of days in a month.
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  /// Checks if a year is a leap year.
  static bool isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }
  
  /// Gets the Sri Lankan season for a given date.
  static String getSriLankanSeason(DateTime date) {
    final month = date.month;
    
    if (month >= 12 || month <= 2) {
      return 'North-East Monsoon';
    } else if (month >= 3 && month <= 4) {
      return 'First Inter-Monsoon';
    } else if (month >= 5 && month <= 9) {
      return 'South-West Monsoon';
    } else {
      return 'Second Inter-Monsoon';
    }
  }
  
  /// Checks if a date is during Sri Lankan peak tourist season.
  static bool isPeakTouristSeason(DateTime date) {
    final month = date.month;
    // Peak seasons: December-March and July-August
    return (month >= 12 || month <= 3) || (month >= 7 && month <= 8);
  }
  
  /// Gets the best time to visit a destination in Sri Lanka.
  static String getBestTimeToVisit(String destination) {
    switch (destination.toLowerCase()) {
      case 'colombo':
      case 'negombo':
      case 'galle':
      case 'bentota':
        return 'December to March';
        
      case 'kandy':
      case 'nuwara eliya':
      case 'ella':
        return 'January to April';
        
      case 'jaffna':
      case 'trincomalee':
        return 'May to September';
        
      case 'arugam bay':
        return 'April to October';
        
      case 'yala':
      case 'udawalawe':
        return 'February to July';
        
      default:
        return 'December to March';
    }
  }
}