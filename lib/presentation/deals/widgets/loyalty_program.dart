import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/user.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class LoyaltyProgram extends StatelessWidget {
  final int points;
  final int tier;
  final int pointsToNextTier;
  final List<LoyaltyReward> availableRewards;
  final List<LoyaltyActivity> recentActivity;
  final VoidCallback onViewAllRewards;
  final VoidCallback onViewAllActivity;
  final Function(LoyaltyReward) onRedeemReward;

  const LoyaltyProgram({
    super.key,
    required this.points,
    required this.tier,
    required this.pointsToNextTier,
    required this.availableRewards,
    required this.recentActivity,
    required this.onViewAllRewards,
    required this.onViewAllActivity,
    required this.onRedeemReward,
  });
  
  get tierName => null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierName = _getTierName(tier);
    final tierColor = _getTierColor(tier);
    final nextTierName = _getTierName(tier + 1);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tier info
          Row(
            children: [
              _buildTierBadge(tierName, tierColor),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taprobana Rewards',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Earn points with every booking',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      NumberFormat('#,###').format(points),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Progress to next tier
          if (tier < 4) // If not at max tier
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$tierName Tier',
                      style: TextStyle(
                        color: tierColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$nextTierName Tier',
                      style: TextStyle(
                        color: _getTierColor(tier + 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 10.0,
                  percent: _calculateTierProgress(),
                  backgroundColor: Colors.grey[300],
                  progressColor: _getTierColor(tier + 1),
                  barRadius: Radius.circular(5),
                ),
                SizedBox(height: 8),
                Text(
                  '$pointsToNextTier points to reach $nextTierName Tier',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 12),
                Divider(),
              ],
            ),
            
          SizedBox(height: 16),
          
          // Available rewards
          _buildSectionHeader(
            context, 
            'Available Rewards', 
            onViewAllRewards,
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: availableRewards.isEmpty
              ? _buildEmptyRewards(context)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableRewards.length > 3 
                    ? 3 
                    : availableRewards.length,
                  itemBuilder: (context, index) {
                    final reward = availableRewards[index];
                    return _buildRewardCard(
                      context, 
                      reward,
                      () => onRedeemReward(reward),
                    );
                  },
                ),
          ),
          
          SizedBox(height: 20),
          
          // Recent activity
          _buildSectionHeader(
            context, 
            'Recent Activity', 
            onViewAllActivity,
          ),
          SizedBox(height: 12),
          recentActivity.isEmpty
            ? _buildEmptyActivity(context)
            : Column(
                children: recentActivity
                  .take(3)
                  .map((activity) => _buildActivityItem(context, activity))
                  .toList(),
              ),
              
          SizedBox(height: 20),
          
          // Membership benefits
          _buildMembershipBenefits(context),
        ],
      ),
    );
  }
  
  Widget _buildTierBadge(String tierName, Color tierColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: tierColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          tierName[0],
          style: TextStyle(
            color: tierColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(
    BuildContext context, 
    String title, 
    VoidCallback onViewAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text('View All'),
        ),
      ],
    );
  }
  
  Widget _buildRewardCard(
    BuildContext context,
    LoyaltyReward reward,
    VoidCallback onRedeem,
  ) {
    final theme = Theme.of(context);
    final isAffordable = points >= reward.pointsCost;
    
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isAffordable 
          ? theme.colorScheme.surface 
          : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAffordable 
            ? theme.colorScheme.primary.withOpacity(0.3) 
            : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reward icon and points
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAffordable 
                ? theme.colorScheme.primary.withOpacity(0.1) 
                : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  _getRewardIcon(reward.category),
                  color: isAffordable 
                    ? theme.colorScheme.primary 
                    : Colors.grey,
                  size: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAffordable 
                      ? theme.colorScheme.primary 
                      : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${reward.pointsCost}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Reward details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isAffordable 
                      ? theme.colorScheme.onSurface 
                      : Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: isAffordable ? onRedeem : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 30),
                    padding: EdgeInsets.zero,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                  child: Text('Redeem'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(BuildContext context, LoyaltyActivity activity) {
    final theme = Theme.of(context);
    final isPointsAdded = activity.pointsChange > 0;
    final formattedDate = DateFormat('MMM dd, yyyy').format(activity.date);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPointsAdded 
                ? Colors.green.withOpacity(0.1) 
                : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isPointsAdded ? Icons.add : Icons.remove,
                color: isPointsAdded ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Points
          Text(
            isPointsAdded 
              ? '+${activity.pointsChange}' 
              : '${activity.pointsChange}',
            style: TextStyle(
              color: isPointsAdded ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyRewards(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 40,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'No rewards available yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Earn more points to unlock rewards',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyActivity(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 32,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'No activity yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your reward activity will appear here',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembershipBenefits(BuildContext context) {
    final theme = Theme.of(context);
    final benefits = _getTierBenefits(tier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your $tierName Benefits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  benefit,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  String _getTierName(int tier) {
    switch (tier) {
      case 1:
        return 'Bronze';
      case 2:
        return 'Silver';
      case 3:
        return 'Gold';
      case 4:
        return 'Platinum';
      default:
        return 'Bronze';
    }
  }
  
  Color _getTierColor(int tier) {
    switch (tier) {
      case 1:
        return Color(0xFFCD7F32); // Bronze
      case 2:
        return Color(0xFFC0C0C0); // Silver
      case 3:
        return Color(0xFFFFD700); // Gold
      case 4:
        return Color(0xFFE5E4E2); // Platinum
      default:
        return Color(0xFFCD7F32); // Bronze
    }
  }
  
  double _calculateTierProgress() {
    // Logic to calculate progress to next tier
    // This is simplified - you would use actual tier thresholds
    final tierThresholds = [0, 1000, 5000, 15000, 30000];
    
    if (tier >= 4) return 1.0; // Max tier
    
    final currentTierPoints = tierThresholds[tier];
    final nextTierPoints = tierThresholds[tier + 1];
    final totalPointsNeeded = nextTierPoints - currentTierPoints;
    final pointsEarned = totalPointsNeeded - pointsToNextTier;
    
    return pointsEarned / totalPointsNeeded;
  }
  
  IconData _getRewardIcon(String category) {
    switch (category.toLowerCase()) {
      case 'discount':
        return Icons.discount;
      case 'voucher':
        return Icons.card_giftcard;
      case 'upgrade':
        return Icons.upgrade;
      case 'freebie':
        return Icons.redeem;
      case 'experience':
        return Icons.star;
      default:
        return Icons.card_giftcard;
    }
  }
  
  List<String> _getTierBenefits(int tier) {
    final basicBenefits = [
      'Earn 1 point for every \$1 spent',
      'Access to member-only deals',
    ];
    
    final silverBenefits = [
      'Earn 1.5 points for every \$1 spent',
      'Priority customer support',
      'Free cancellation up to 24 hours before',
    ];
    
    final goldBenefits = [
      'Earn 2 points for every \$1 spent',
      'Room upgrades when available',
      'Early check-in and late check-out',
      'Welcome drink at partner hotels',
    ];
    
    final platinumBenefits = [
      'Earn 3 points for every \$1 spent',
      'Dedicated concierge service',
      'Complimentary airport transfers',
      'Guaranteed room availability',
      'Exclusive access to VIP events',
    ];
    
    switch (tier) {
      case 1:
        return basicBenefits;
      case 2:
        return [...basicBenefits, ...silverBenefits];
      case 3:
        return [...basicBenefits, ...silverBenefits, ...goldBenefits];
      case 4:
        return [...basicBenefits, ...silverBenefits, ...goldBenefits, ...platinumBenefits];
      default:
        return basicBenefits;
    }
  }
}

/// Model classes needed for this widget

class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String category; // discount, voucher, upgrade, freebie, experience
  final DateTime? expiryDate;
  
  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.category,
    this.expiryDate,
  });
}

class LoyaltyActivity {
  final String id;
  final String description;
  final int pointsChange;
  final DateTime date;
  final String? referenceId; // e.g., booking ID
  final String? category;
  
  LoyaltyActivity({
    required this.id,
    required this.description,
    required this.pointsChange,
    required this.date,
    this.referenceId,
    this.category,
  });
}

// Example usage:
// LoyaltyProgram(
//   points: 2500,
//   tier: 2,
//   pointsToNextTier: 2500,
//   availableRewards: [
//     LoyaltyReward(
//       id: 'reward1',
//       title: '10% Off Hotel Booking',
//       description: 'Get 10% off on your next hotel booking',
//       pointsCost: 1000,
//       category: 'discount',
//     ),
//     // Add more rewards
//   ],
//   recentActivity: [
//     LoyaltyActivity(
//       id: 'activity1',
//       description: 'Hotel booking at Cinnamon Grand',
//       pointsChange: 250,
//       date: DateTime.now().subtract(Duration(days: 5)),
//       referenceId: 'B12345',
//       category: 'booking',
//     ),
//     // Add more activities
//   ],
//   onViewAllRewards: () {
//     // Navigate to rewards screen
//   },
//   onViewAllActivity: () {
//     // Navigate to activity history screen
//   },
//   onRedeemReward: (reward) {
//     // Handle reward redemption
//   },
// )