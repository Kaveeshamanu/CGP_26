import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../../bloc/itinerary/itinerary_bloc.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../data/models/itinerary.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/date_utils.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import 'widgets/activity_card.dart';
import 'widgets/budget_calculator.dart';

class DayScheduleScreen extends StatefulWidget {
  final String itineraryId;
  final int day;
  
  const DayScheduleScreen({
    super.key,
    required this.itineraryId,
    required this.day, required date,
  });

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  late Itinerary _itinerary;
  List<ItineraryActivity> _activities = [];
  late DateTime _dayDate;
  bool _isEditMode = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }
  
  Future<void> _loadItinerary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Load itinerary from the bloc
      context.read<ItineraryBloc>().add(LoadItineraryDetails(widget.itineraryId));
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load itinerary: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  void _addActivity() {
    _showAddActivityDialog();
  }
  
  void _editActivity(ItineraryActivity activity) {
    _showEditActivityDialog(activity);
  }
  
  void _deleteActivity(String activityId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Activity'),
        content: Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Remove activity
              context.read<ItineraryBloc>().add(
                RemoveItineraryActivity(
                  itineraryId: widget.itineraryId,
                  activityId: activityId,
                ),
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Activity deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }
  
  void _navigateToNextDay() {
    if (widget.day < _itinerary.getDuration()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DayScheduleScreen(
            itineraryId: widget.itineraryId,
            day: widget.day + 1,
          ),
        ),
      );
    }
  }
  
  void _navigateToPreviousDay() {
    if (widget.day > 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DayScheduleScreen(
            itineraryId: widget.itineraryId,
            day: widget.day - 1,
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Day ${widget.day}',
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: BlocListener<ItineraryBloc, ItineraryState>(
        listener: (context, state) {
          if (state is ItineraryDetailsLoaded) {
            setState(() {
              _itinerary = state.itinerary;
              _activities = state.itinerary.getActivitiesForDay(widget.day);
              // Sort activities by time if available
              _activities.sort((a, b) {
                if (a.time == null && b.time == null) return 0;
                if (a.time == null) return 1;
                if (b.time == null) return -1;
                
                final format = DateFormat.jm();
                final timeA = format.parse(a.time!);
                final timeB = format.parse(b.time!);
                return timeA.compareTo(timeB);
              });
              
              // Calculate day date
              _dayDate = _itinerary.startDate.add(Duration(days: widget.day - 1));
              _isLoading = false;
            });
          } else if (state is ItineraryError) {
            setState(() {
              _errorMessage = state.message;
              _isLoading = false;
            });
          }
        },
        child: BlocBuilder<ItineraryBloc, ItineraryState>(
          builder: (context, state) {
            if (_isLoading) {
              return Center(child: LoadingSpinner());
            }
            
            if (_errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadItinerary,
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                // Day header
                _buildDayHeader(),
                
                // Activities timeline
                Expanded(
                  child: _activities.isEmpty
                    ? _buildEmptyState()
                    : _buildActivitiesTimeline(),
                ),
                
                // Day navigation and add activity button
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _isEditMode
        ? FloatingActionButton(
            onPressed: _addActivity,
            child: Icon(Icons.add),
            tooltip: 'Add Activity',
          )
        : null,
    );
  }
  
  Widget _buildDayHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_dayDate),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.map,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 4),
              Text(
                _itinerary.getDestinationName(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.event_note,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              SizedBox(width: 4),
              Text(
                'Day ${widget.day} of ${_itinerary.getDuration()}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Activities Planned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add activities',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          if (!_isEditMode)
            ElevatedButton.icon(
              onPressed: _toggleEditMode,
              icon: Icon(Icons.edit),
              label: Text('Edit Day Plan'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActivitiesTimeline() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        final isFirst = index == 0;
        final isLast = index == _activities.length - 1;
        
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.2,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 40,
            height: 40,
            indicator: _buildActivityIcon(activity),
            drawGap: true,
            padding: EdgeInsets.all(8),
          ),
          beforeLineStyle: LineStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            thickness: 2,
          ),
          afterLineStyle: LineStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            thickness: 2,
          ),
          startChild: Container(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              activity.time ?? 'All day',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          endChild: Container(
            margin: EdgeInsets.only(left: 16, bottom: 24),
            child: InkWell(
              onTap: _isEditMode ? () => _editActivity(activity) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (_isEditMode)
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: () => _deleteActivity(activity.id),
                          ),
                      ],
                    ),
                    if (activity.location != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.location!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (activity.notes != null) ...[
                      SizedBox(height: 8),
                      Text(
                        activity.notes!,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (activity.cost != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '\$${activity.cost!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActivityIcon(ItineraryActivity activity) {
    return Container(
      decoration: BoxDecoration(
        color: _getActivityColor(activity.type).withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getActivityColor(activity.type),
          width: 2,
        ),
      ),
      child: Icon(
        _getActivityIcon(activity.type),
        color: _getActivityColor(activity.type),
        size: 18,
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous day button
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: widget.day > 1 ? _navigateToPreviousDay : null,
            color: widget.day > 1
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          
          // Day indicator
          Text(
            'Day ${widget.day} of ${_itinerary.getDuration()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Next day button
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: widget.day < _itinerary.getDuration() ? _navigateToNextDay : null,
            color: widget.day < _itinerary.getDuration()
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
  
  void _showAddActivityDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    final costController = TextEditingController();
    
    String type = 'sightseeing';
    String? time;
    TimeOfDay? selectedTime;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Activity for Day ${widget.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity type
                          Text(
                            'Activity Type',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildActivityTypeChip(
                                'Sightseeing',
                                'sightseeing',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Food',
                                'food',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Transport',
                                'transport',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Accommodation',
                                'accommodation',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Adventure',
                                'adventure',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Shopping',
                                'shopping',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Relaxation',
                                'relaxation',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Other',
                                'other',
                                type,
                                (value) => setState(() => type = value),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Activity title
                          Text(
                            'Activity Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Visit Temple of the Tooth',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an activity title';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Time selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time (Optional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (selectedTime != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedTime = null;
                                      time = null;
                                    });
                                  },
                                  child: Text('Clear'),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              
                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = pickedTime;
                                  
                                  // Format time
                                  final now = DateTime.now();
                                  final dateTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                  time = DateFormat.jm().format(dateTime);
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    selectedTime != null
                                      ? time!
                                      : 'Select a time (optional)',
                                    style: TextStyle(
                                      color: selectedTime != null
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Location
                          Text(
                            'Location (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: locationController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Kandy, Sri Lanka',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Cost
                          Text(
                            'Cost (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: costController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'e.g., 25.00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Notes
                          Text(
                            'Notes (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any notes about this activity...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Add button
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter an activity title'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        
                        // Create new activity
                        final activity = ItineraryActivity(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          type: type,
                          day: widget.day,
                          time: time,
                          location: locationController.text.isNotEmpty 
                            ? locationController.text 
                            : null,
                          notes: notesController.text.isNotEmpty 
                            ? notesController.text 
                            : null,
                          cost: costController.text.isNotEmpty 
                            ? double.tryParse(costController.text) 
                            : null,
                        );
                        
                        // Add activity to itinerary
                        context.read<ItineraryBloc>().add(
                          AddItineraryActivity(
                            itineraryId: widget.itineraryId,
                            activity: activity,
                          ),
                        );
                        
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Activity added'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Add Activity'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _showEditActivityDialog(ItineraryActivity activity) {
    final titleController = TextEditingController(text: activity.title);
    final locationController = TextEditingController(text: activity.location ?? '');
    final notesController = TextEditingController(text: activity.notes ?? '');
    final costController = TextEditingController(
      text: activity.cost != null ? activity.cost.toString() : '',
    );
    
    String type = activity.type;
    String? time = activity.time;
    TimeOfDay? selectedTime;
    
    // Parse time if available
    if (time != null) {
      final format = DateFormat.jm();
      final dateTime = format.parse(time);
      selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Activity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity type
                          Text(
                            'Activity Type',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildActivityTypeChip(
                                'Sightseeing',
                                'sightseeing',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Food',
                                'food',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Transport',
                                'transport',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Accommodation',
                                'accommodation',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Adventure',
                                'adventure',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Shopping',
                                'shopping',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Relaxation',
                                'relaxation',
                                type,
                                (value) => setState(() => type = value),
                              ),
                              _buildActivityTypeChip(
                                'Other',
                                'other',
                                type,
                                (value) => setState(() => type = value),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Activity title
                          Text(
                            'Activity Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Visit Temple of the Tooth',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an activity title';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Time selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time (Optional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (selectedTime != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedTime = null;
                                      time = null;
                                    });
                                  },
                                  child: Text('Clear'),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              
                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = pickedTime;
                                  
                                  // Format time
                                  final now = DateTime.now();
                                  final dateTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                  time = DateFormat.jm().format(dateTime);
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    selectedTime != null
                                      ? time!
                                      : 'Select a time (optional)',
                                    style: TextStyle(
                                      color: selectedTime != null
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Location
                          Text(
                            'Location (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: locationController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Kandy, Sri Lanka',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Cost
                          Text(
                            'Cost (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: costController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'e.g., 25.00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Notes
                          Text(
                            'Notes (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any notes about this activity...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Buttons
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Delete the activity
                              context.read<ItineraryBloc>().add(
                                RemoveItineraryActivity(
                                  itineraryId: widget.itineraryId,
                                  activityId: activity.id,
                                ),
                              );
                              
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Activity deleted'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 48),
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                            ),
                            child: Text('Delete'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (titleController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please enter an activity title'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              
                              // Update activity
                              final updatedActivity = ItineraryActivity(
                                id: activity.id,
                                title: titleController.text,
                                type: type,
                                day: widget.day,
                                time: time,
                                location: locationController.text.isNotEmpty 
                                  ? locationController.text 
                                  : null,
                                notes: notesController.text.isNotEmpty 
                                  ? notesController.text 
                                  : null,
                                cost: costController.text.isNotEmpty 
                                  ? double.tryParse(costController.text) 
                                  : null,
                              );
                              
                              // Update activity in itinerary
                              context.read<ItineraryBloc>().add(
                                UpdateItineraryActivity(
                                  itineraryId: widget.itineraryId,
                                  activity: updatedActivity,
                                ),
                              );
                              
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Activity updated'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 48),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildActivityTypeChip(
    String label,
    String value,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = value == selectedValue;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getActivityIcon(value),
              size: 16,
              color: isSelected
                ? Colors.white
                : theme.colorScheme.primary,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface,
                fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sightseeing':
        return Icons.photo_camera;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'adventure':
        return Icons.terrain;
      case 'shopping':
        return Icons.shopping_bag;
      case 'relaxation':
        return Icons.spa;
      default:
        return Icons.star;
    }
  }
  
  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'sightseeing':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.green;
      case 'accommodation':
        return Colors.purple;
      case 'adventure':
        return Colors.red;
      case 'shopping':
        return Colors.pink;
      case 'relaxation':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

// Helper model class for the screen
class ItineraryActivity {
  final String id;
  final String title;
  final String type;
  final int day;
  final String? time;
  final String? location;
  final String? notes;
  final double? cost;
  
  ItineraryActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.day,
    this.time,
    this.location,
    this.notes,
    this.cost,
  });
  
  ItineraryActivity copyWith({
    String? id,
    String? title,
    String? type,
    int? day,
    String? time,
    String? location,
    String? notes,
    double? cost,
  }) {
    return ItineraryActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      day: day ?? this.day,
      time: time ?? this.time,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
    );
  }
}

// Extension methods for Itinerary model
extension ItineraryExtensions on Itinerary {
  int getDuration() {
    return endDate.difference(startDate).inDays + 1;
  }
  
  List<ItineraryActivity> getActivitiesForDay(int day) {
    return activities.where((activity) => activity.day == day).toList();
  }
  
  String getDestinationName() {
    // This would typically come from a lookup to the destination repository
    // For this example, we'll return a placeholder
    return 'Sri Lanka';
  }
}