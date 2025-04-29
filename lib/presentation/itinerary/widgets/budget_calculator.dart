import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:taprobana_trails/presentation/itinerary/widgets/activity_card.dart';
import 'package:taprobana_trails/presentation/itinerary/widgets/calendar_view.dart';

import '../../../config/theme.dart';
import '../../../data/models/itinerary.dart';
import '../../../bloc/itinerary/itinerary_bloc.dart';
import '../../../bloc/itinerary/itinerary_state.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

class BudgetCalculator extends StatelessWidget {
  final String? itineraryId;
  final double? totalBudget;
  final List<Activity>? activities;
  final bool showAddButton;
  final VoidCallback? onAddBudgetTap;
  final VoidCallback? onEditBudgetTap;

  const BudgetCalculator({
    super.key,
    this.itineraryId,
    this.totalBudget,
    this.activities,
    this.showAddButton = true,
    this.onAddBudgetTap,
    this.onEditBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    // If activities and totalBudget are provided directly, use them
    // Otherwise, get them from BLoC state
    return BlocBuilder<ItineraryBloc, ItineraryState>(
      builder: (context, state) {
        if (activities != null && totalBudget != null) {
          return _buildBudgetContent(
            context,
            activities!,
            totalBudget!,
          );
        }

        if (state is ItineraryLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ItineraryLoadedState && state.itinerary.id == itineraryId) {
          final currentTotalBudget = state.itinerary.totalBudget;
          
          if (currentTotalBudget == null || currentTotalBudget <= 0) {
            return _buildNoBudgetContent(context);
          }
          
          return _buildBudgetContent(
            context,
            state.itinerary.activities,
            currentTotalBudget,
          );
        }

        return const Center(
          child: Text('No budget information available'),
        );
      },
    );
  }

  Widget _buildNoBudgetContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No budget set for this trip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set a budget to track your expenses and plan better',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (showAddButton && onAddBudgetTap != null)
              ElevatedButton.icon(
                onPressed: onAddBudgetTap,
                icon: const Icon(Icons.add),
                label: const Text('Set Budget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetContent(
    BuildContext context,
    List<Activity> activityList,
    double budget,
  ) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    // Calculate total spent
    final totalSpent = activityList.fold<double>(
      0,
      (sum, activity) => sum + (activity.cost ?? 0),
    );
    
    // Calculate spending by category
    final Map<ActivityCategory, double> spendingByCategory = {};
    for (final activity in activityList) {
      if (activity.cost != null && activity.cost! > 0) {
        spendingByCategory[activity.category] = 
            (spendingByCategory[activity.category] ?? 0) + activity.cost!;
      }
    }

    // Sort categories by spend amount (descending)
    final sortedCategories = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate percentages
    final budgetUsagePercent = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = budget - totalSpent;
    final isOverBudget = remaining < 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trip Budget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEditBudgetTap != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEditBudgetTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 50,
                  lineWidth: 10.0,
                  percent: budgetUsagePercent,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(budgetUsagePercent * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'used',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  progressColor: _getBudgetStatusColor(budgetUsagePercent),
                  backgroundColor: Colors.grey[200]!,
                  animation: true,
                  animationDuration: 1000,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Budget',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currencyFormatter.format(budget),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Spent So Far',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currencyFormatter.format(totalSpent),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverBudget ? 'Over Budget' : 'Remaining',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : Colors.green[700],
                  ),
                ),
                Text(
                  currencyFormatter.format(remaining.abs()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: budgetUsagePercent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              progressColor: _getBudgetStatusColor(budgetUsagePercent),
              barRadius: const Radius.circular(4),
              animation: true,
              animationDuration: 1000,
              padding: EdgeInsets.zero,
            ),
            if (spendingByCategory.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...sortedCategories.take(4).map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final percentage = amount / totalSpent;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getCategoryName(category),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(amount),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearPercentIndicator(
                        lineHeight: 8.0,
                        percent: percentage,
                        backgroundColor: Colors.grey[200],
                        progressColor: _getCategoryColor(category),
                        barRadius: const Radius.circular(4),
                        animation: true,
                        animationDuration: 1000,
                        trailing: Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        padding: const EdgeInsets.only(right: 8),
                      ),
                    ],
                  ),
                );
              }),
              
              // If there are more categories not shown
              if (sortedCategories.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '+ ${sortedCategories.length - 4} more categories',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBudgetStatusColor(double percentUsed) {
    if (percentUsed < 0.6) {
      return Colors.green;
    } else if (percentUsed < 0.85) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  String _getCategoryName(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.attraction:
        return 'Attractions';
      case ActivityCategory.dining:
        return 'Dining';
      case ActivityCategory.accommodation:
        return 'Accommodation';
      case ActivityCategory.transportation:
        return 'Transportation';
      case ActivityCategory.shopping:
        return 'Shopping';
      case ActivityCategory.event:
        return 'Events';
      case ActivityCategory.other:
      default:
        return 'Other';
    }
  }
  
  Color _getCategoryColor(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.attraction:
        return Colors.blue;
      case ActivityCategory.dining:
        return Colors.orange;
      case ActivityCategory.accommodation:
        return Colors.purple;
      case ActivityCategory.transportation:
        return Colors.green;
      case ActivityCategory.shopping:
        return Colors.pink;
      case ActivityCategory.event:
        return Colors.amber;
      case ActivityCategory.other:
      default:
        return Colors.grey;
    }
  }
}