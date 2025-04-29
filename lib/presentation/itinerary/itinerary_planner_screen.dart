import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../../bloc/itinerary/itinerary_bloc.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../data/models/destination.dart';
import '../../data/models/itinerary.dart';
import '../../data/models/accommodation.dart';
import '../../data/models/restaurant.dart';
import '../../data/models/transport.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import 'widgets/calendar_view.dart';
import 'widgets/activity_card.dart';
import 'widgets/budget_calculator.dart';

class ItineraryPlannerScreen extends StatefulWidget {
  final String? destinationId; // Optional: Pre-select a destination
  
  const ItineraryPlannerScreen({
    super.key,
    this.destinationId,
  });

  @override
  State<ItineraryPlannerScreen> createState() => _ItineraryPlannerScreenState();
}

class _ItineraryPlannerScreenState extends State<ItineraryPlannerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Itinerary parameters
  DateTime _startDate = DateTime.now().add(Duration(days: 7));
  DateTime _endDate = DateTime.now().add(Duration(days: 14));
  String? _selectedDestinationId;
  List<Destination> _availableDestinations = [];
  final List<ItineraryActivity> _activities = [];
  bool _isPublic = false;
  
  // UI state
  int _currentStep = 0;
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    
    // If destination is passed, pre-select it
    if (widget.destinationId != null) {
      _selectedDestinationId = widget.destinationId;
    }
    
    // Load available destinations
    context.read<ItineraryBloc>().add(LoadAvailableDestinations());
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _onDateRangeSelected(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }
  
  void _onDestinationSelected(String destinationId) {
    setState(() {
      _selectedDestinationId = destinationId;
    });
    
    // Load activities for this destination
    context.read<ItineraryBloc>().add(LoadDestinationActivities(destinationId));
  }
  
  void _addActivity(ItineraryActivity activity) {
    setState(() {
      _activities.add(activity);
    });
  }
  
  void _removeActivity(String activityId) {
    setState(() {
      _activities.removeWhere((activity) => activity.id == activityId);
    });
  }
  
  void _updateActivity(ItineraryActivity updatedActivity) {
    setState(() {
      final index = _activities.indexWhere((activity) => activity.id == updatedActivity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }
    });
  }
  
  void _moveActivityToDay(String activityId, int fromDay, int toDay) {
    setState(() {
      final activity = _activities.firstWhere((a) => a.id == activityId);
      final updatedActivity = activity.copyWith(day: toDay);
      _updateActivity(updatedActivity);
    });
  }
  
  Future<void> _saveItinerary() async {
    if (_selectedDestinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a destination'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title for your itinerary'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final itinerary = Itinerary(
        id: const Uuid().v4(),
        title: _titleController.text,
        destinationId: _selectedDestinationId!,
        startDate: _startDate,
        endDate: _endDate,
        activities: _activities,
        notes: _notesController.text,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      context.read<ItineraryBloc>().add(SaveItinerary(itinerary));
      
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Itinerary saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate to itinerary details
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.itineraryDetails,
        arguments: itinerary.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save itinerary: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Plan Your Trip',
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: BlocBuilder<ItineraryBloc, ItineraryState>(
        builder: (context, state) {
          if (state is ItineraryLoading && !state.isPartial) {
            return Center(child: LoadingSpinner());
          }
          
          if (state is ItineraryError) {
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
                    'Failed to load itinerary data',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ItineraryBloc>().add(LoadAvailableDestinations());
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          // Get the destinations from the state if available
          if (state is ItineraryDestinationsLoaded) {
            _availableDestinations = state.destinations;
          }
          
          // Show stepper UI
          return Column(
            children: [
              Expanded(
                child: Stepper(
                  type: StepperType.vertical,
                  physics: ClampingScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    setState(() {
                      _currentStep = step;
                    });
                  },
                  onStepContinue: () {
                    if (_currentStep < 3) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      _saveItinerary();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(
                              _currentStep == 3 ? 'Save Itinerary' : 'Continue',
                            ),
                          ),
                          SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text(
                              _currentStep == 0 ? 'Cancel' : 'Back',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    // Step 1: Destination & Date Selection
                    Step(
                      title: Text('Choose Destination & Dates'),
                      content: _buildDestinationAndDatesStep(),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    ),
                    
                    // Step 2: Itinerary Details
                    Step(
                      title: Text('Trip Details'),
                      content: _buildTripDetailsStep(),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    ),
                    
                    // Step 3: Activities
                    Step(
                      title: Text('Plan Activities'),
                      content: _buildActivitiesStep(state),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    ),
                    
                    // Step 4: Review and Save
                    Step(
                      title: Text('Review & Save'),
                      content: _buildReviewStep(),
                      isActive: _currentStep >= 3,
                      state: StepState.indexed,
                    ),
                  ],
                ),
              ),
              
              // Loading overlay
              if (_isSubmitting)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: LoadingSpinner(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDestinationAndDatesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destination selection
        Text(
          'Select Your Destination',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        
        if (_availableDestinations.isNotEmpty)
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableDestinations.length,
              itemBuilder: (context, index) {
                final destination = _availableDestinations[index];
                final isSelected = destination.id == _selectedDestinationId;
                
                return GestureDetector(
                  onTap: () => _onDestinationSelected(destination.id),
                  child: Container(
                    width: 150,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          // Destination image
                          CachedNetworkImage(
                            imageUrl: destination.images.first,
                            height: 200,
                            width: 150,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                          
                          // Gradient overlay for text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: [0.6, 1.0],
                              ),
                            ),
                          ),
                          
                          // Destination name
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Text(
                              destination.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Selected checkmark
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Center(
            child: Text('Loading destinations...'),
          ),
        
        SizedBox(height: 24),
        
        // Date selection
        Text(
          'Select Your Trip Dates',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: 'Start Date',
                date: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                label: 'End Date',
                date: _endDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8),
        
        // Trip duration
        Text(
          'Trip Duration: ${_endDate.difference(_startDate).inDays + 1} days',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate 
      ? DateTime.now() 
      : _startDate;
    final lastDate = DateTime.now().add(Duration(days: 365));
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    
    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          // If end date is before new start date, adjust it
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(Duration(days: 1));
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }
  
  Widget _buildTripDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip title
        Text(
          'Trip Title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Beach Getaway in Sri Lanka',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        SizedBox(height: 24),
        
        // Trip notes
        Text(
          'Notes (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add any notes about your trip...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        SizedBox(height: 24),
        
        // Privacy setting
        Row(
          children: [
            Switch(
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            SizedBox(width: 8),
            Text(
              'Make this itinerary public',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          'Public itineraries can be viewed by other users',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivitiesStep(ItineraryState state) {
    // Group activities by day
    final tripDuration = _endDate.difference(_startDate).inDays + 1;
    final activitiesByDay = groupBy<ItineraryActivity, int>(
      _activities,
      (activity) => activity.day,
    );
    
    // Get suggested activities if loaded
    if (state is ItineraryActivitiesLoaded) {
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Your Activities',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Add activities for each day of your trip.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 16),
        
        // Calendar day selector
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tripDuration,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = _startDate.add(Duration(days: index));
              final activitiesCount = activitiesByDay[day]?.length ?? 0;
              
              return GestureDetector(
                onTap: () {
                  _showDayActivitiesDialog(day, date, activitiesByDay[day] ?? []);
                },
                child: Container(
                  width: 60,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activitiesCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (activitiesCount > 0)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$activitiesCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: 24),
        
        // Add activity button
        ElevatedButton.icon(
          onPressed: () {
            _showAddActivityDialog();
          },
          icon: Icon(Icons.add),
          label: Text('Add Activity'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Activities overview
        Text(
          'Activities Overview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        
        if (_activities.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No activities added yet. Click "Add Activity" to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _activities.length > 5 ? 5 : _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getActivityColor(activity.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          _getActivityIcon(activity.type),
                          color: _getActivityColor(activity.type),
                          size: 20,
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Activity details
                    Expanded(
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
                                  ),
                                ),
                              ),
                              Text(
                                'Day ${activity.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if (activity.location != null) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    activity.location!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (activity.time != null) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  activity.time!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Edit button
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showEditActivityDialog(activity);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        
        if (_activities.length > 5) ...[
          SizedBox(height: 8),
          Center(
            child: Text(
              'And ${_activities.length - 5} more activities...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildReviewStep() {
    // Group activities by day
    final tripDuration = _endDate.difference(_startDate).inDays + 1;
    final activitiesByDay = groupBy<ItineraryActivity, int>(
      _activities,
      (activity) => activity.day,
    );
    
    // Calculate estimated budget
    double totalBudget = 0;
    for (final activity in _activities) {
      if (activity.cost != null) {
        totalBudget += activity.cost!;
      }
    }
    
   return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Itinerary summary
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleController.text.isEmpty 
                  ? 'Untitled Trip' 
                  : _titleController.text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              if (_selectedDestinationId != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _availableDestinations
                        .firstWhere((d) => d.id == _selectedDestinationId)
                        .name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
              ],
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.timelapse,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$tripDuration days',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (_activities.isNotEmpty) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${_activities.length} activities planned',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
              if (totalBudget > 0) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Estimated budget: \$${totalBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
              if (_notesController.text.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _notesController.text,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Activities by day
        Text(
          'Activities Schedule',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        
        if (_activities.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No activities added. You can still save this itinerary and add activities later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tripDuration,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = _startDate.add(Duration(days: index));
              final dayActivities = activitiesByDay[day] ?? [];
              
              // Skip days with no activities
              if (dayActivities.isEmpty) {
                return SizedBox();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Day $day - ${DateFormat('EEE, MMM dd').format(date)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...dayActivities.map((activity) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Activity icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getActivityColor(activity.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              _getActivityIcon(activity.type),
                              color: _getActivityColor(activity.type),
                              size: 20,
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Activity details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (activity.time != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  activity.time!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                              if (activity.location != null) ...[
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        activity.location!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (activity.cost != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  '\$${activity.cost!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(height: 8),
                ],
              );
            },
          ),
        
        SizedBox(height: 24),
        
        // Privacy notice
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isPublic 
              ? Colors.green.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPublic ? Colors.green : Colors.blue,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isPublic ? Icons.public : Icons.lock,
                color: _isPublic ? Colors.green : Colors.blue,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPublic ? 'Public Itinerary' : 'Private Itinerary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isPublic ? Colors.green : Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isPublic 
                        ? 'This itinerary will be visible to other users.'
                        : 'This itinerary will be visible only to you.',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showDayActivitiesDialog(int day, DateTime date, List<ItineraryActivity> activities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                      'Day $day - ${DateFormat('EEE, MMM dd').format(date)}',
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
              
              // Activities list
              Expanded(
                child: activities.isEmpty
                  ? Center(
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
                            'No activities planned for this day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the button below to add activities',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        
                        return Dismissible(
                          key: Key(activity.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _removeActivity(activity.id);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                _showEditActivityDialog(activity);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Activity icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getActivityColor(activity.type).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getActivityIcon(activity.type),
                                        color: _getActivityColor(activity.type),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(width: 12),
                                  
                                  // Activity details
                                  Expanded(
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
                                                ),
                                              ),
                                            ),
                                            if (activity.time != null)
                                              Text(
                                                activity.time!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (activity.location != null) ...[
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  activity.location!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (activity.notes != null) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            activity.notes!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (activity.cost != null) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            '\$${activity.cost!.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  // Edit button
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    constraints: BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      _showEditActivityDialog(activity);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
              
              // Add activity button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddActivityDialog(preselectedDay: day);
                  },
                  icon: Icon(Icons.add),
                  label: Text(
                    activities.isEmpty
                      ? 'Add Activity for Day $day'
                      : 'Add Another Activity',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showAddActivityDialog({int? preselectedDay}) {
    final tripDuration = _endDate.difference(_startDate).inDays + 1;
    
    // Activity form controllers
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    final costController = TextEditingController();
    
    // Activity parameters
    String type = 'sightseeing';
    int day = preselectedDay ?? 1;
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
                          'Add Activity',
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
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Day selection
                          Text(
                            'Day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: day,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: List.generate(tripDuration, (index) {
                              final dayNumber = index + 1;
                              final date = _startDate.add(Duration(days: index));
                              return DropdownMenuItem(
                                value: dayNumber,
                                child: Text(
                                  'Day $dayNumber - ${DateFormat('EEE, MMM dd').format(date)}',
                                ),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  day = value;
                                });
                              }
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
                          day: day,
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
                        
                        // Add to activities list
                        _addActivity(activity);
                        
                        // Close dialog
                        Navigator.pop(context);
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
    final tripDuration = _endDate.difference(_startDate).inDays + 1;
    
    // Activity form controllers
    final titleController = TextEditingController(text: activity.title);
    final locationController = TextEditingController(text: activity.location ?? '');
    final notesController = TextEditingController(text: activity.notes ?? '');
    final costController = TextEditingController(
      text: activity.cost != null ? activity.cost.toString() : '',
    );
    
    // Activity parameters
    String type = activity.type;
    int day = activity.day;
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
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Day selection
                          Text(
                            'Day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: day,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: List.generate(tripDuration, (index) {
                              final dayNumber = index + 1;
                              final date = _startDate.add(Duration(days: index));
                              return DropdownMenuItem(
                                value: dayNumber,
                                child: Text(
                                  'Day $dayNumber - ${DateFormat('EEE, MMM dd').format(date)}',
                                ),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  day = value;
                                });
                              }
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
                              _removeActivity(activity.id);
                              Navigator.pop(context);
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
                                day: day,
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
                              
                              // Update activities list
                              _updateActivity(updatedActivity);
                              
                              // Close dialog
                              Navigator.pop(context);
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
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to Plan Your Trip'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Select Destination & Dates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Choose where you want to go and when you plan to travel.',
              ),
              SizedBox(height: 12),
              
              Text(
                '2. Add Trip Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Give your trip a name and add any notes. You can make your itinerary public if you want to share it with others.',
              ),
              SizedBox(height: 12),
              
              Text(
                '3. Plan Activities',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Add activities for each day of your trip. You can include details like time, location, and cost.',
              ),
              SizedBox(height: 12),
              
              Text(
                '4. Review & Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Review your itinerary before saving it. You can edit it anytime later.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
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

// Helper model classes for the screen
class ActivitySuggestion {
  final String id;
  final String title;
  final String type;
  final String? location;
  final double? cost;
  final String? imageUrl;
  final double? rating;
  
  ActivitySuggestion({
    required this.id,
    required this.title,
    required this.type,
    this.location,
    this.cost,
    this.imageUrl,
    this.rating,
  });
}

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