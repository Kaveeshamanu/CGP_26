import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool showIcons;
  final double height;
  final EdgeInsets padding;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showIcons = true,
    this.height = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return _buildCategoryItem(
            context,
            category,
            isSelected,
            () => onCategorySelected(category),
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12, top: 8, bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            children: [
              if (showIcons) ...[
                _getCategoryIcon(context, category, isSelected),
                SizedBox(width: 6),
              ],
              Text(
                category,
                style: TextStyle(
                  color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                  fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _getCategoryIcon(BuildContext context, String category, bool isSelected) {
    final iconColor = isSelected
      ? Colors.white
      : Theme.of(context).colorScheme.primary;
      
    // Return the appropriate icon based on category
    switch (category.toLowerCase()) {
      case 'all':
        return Icon(
          Icons.dashboard,
          color: iconColor,
          size: 16,
        );
      
      case 'beach':
        return Icon(
          Icons.beach_access,
          color: iconColor,
          size: 16,
        );
      
      case 'mountain':
        return Icon(
          Icons.landscape,
          color: iconColor,
          size: 16,
        );
      
      case 'cultural':
        return Icon(
          Icons.account_balance,
          color: iconColor,
          size: 16,
        );
      
      case 'wildlife':
        return Icon(
          Icons.pets,
          color: iconColor,
          size: 16,
        );
      
      case 'adventure':
        return Icon(
          Icons.explore,
          color: iconColor,
          size: 16,
        );
      
      case 'historical':
        return Icon(
          Icons.history,
          color: iconColor,
          size: 16,
        );
      
      case 'temple':
        return Icon(
          Icons.temple_buddhist,
          color: iconColor,
          size: 16,
        );
      
      case 'waterfall':
        return Icon(
          Icons.water,
          color: iconColor,
          size: 16,
        );
      
      case 'hiking':
        return Icon(
          Icons.hiking,
          color: iconColor,
          size: 16,
        );
      
      case 'surfing':
        return Icon(
          Icons.surfing,
          color: iconColor,
          size: 16,
        );
      
      case 'safari':
        return Icon(
          Icons.directions_car,
          color: iconColor,
          size: 16,
        );
      
      case 'diving':
        return Icon(
          Icons.scuba_diving,
          color: iconColor,
          size: 16,
        );
      
      case 'food':
        return Icon(
          Icons.restaurant,
          color: iconColor,
          size: 16,
        );
      
      case 'shopping':
        return Icon(
          Icons.shopping_bag,
          color: iconColor,
          size: 16,
        );
      
      case 'luxury':
        return Icon(
          Icons.star,
          color: iconColor,
          size: 16,
        );
      
      case 'budget':
        return Icon(
          Icons.savings,
          color: iconColor,
          size: 16,
        );
      
      default:
        return Icon(
          Icons.place,
          color: iconColor,
          size: 16,
        );
    }
  }
}