import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme.dart';

class CuisineFilter extends StatelessWidget {
  final String selectedCuisine;
  final Function(String) onCuisineSelected;
  final bool showIcons;
  final double height;
  final EdgeInsets padding;

  const CuisineFilter({
    super.key,
    required this.selectedCuisine,
    required this.onCuisineSelected,
    this.showIcons = true,
    this.height = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    // List of common cuisine types
    final cuisines = [
      'All',
      'Sri Lankan',
      'Indian',
      'Chinese',
      'Seafood',
      'Italian',
      'Japanese',
      'Thai',
      'Vegetarian',
      'Western',
      'Fast Food',
      'Desserts',
      'Cafe',
    ];

    return Container(
      height: height,
      padding: padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          final cuisine = cuisines[index];
          final isSelected = cuisine == selectedCuisine;
          
          return _buildCuisineItem(
            context,
            cuisine,
            isSelected,
            () => onCuisineSelected(cuisine),
          );
        },
      ),
    );
  }
  
  Widget _buildCuisineItem(
    BuildContext context,
    String cuisine,
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
                _getCuisineIcon(context, cuisine, isSelected),
                SizedBox(width: 6),
              ],
              Text(
                cuisine,
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
  
  Widget _getCuisineIcon(BuildContext context, String cuisine, bool isSelected) {
    final iconColor = isSelected
      ? Colors.white
      : Theme.of(context).colorScheme.primary;
      
    // Return the appropriate icon based on cuisine
    switch (cuisine.toLowerCase()) {
      case 'all':
        return Icon(
          Icons.restaurant_menu,
          color: iconColor,
          size: 16,
        );
      
      case 'sri lankan':
        return Icon(
          Icons.rice_bowl,
          color: iconColor,
          size: 16,
        );
      
      case 'indian':
        return Icon(
          Icons.dining,
          color: iconColor,
          size: 16,
        );
      
      case 'chinese':
        return Icon(
          Icons.ramen_dining,
          color: iconColor,
          size: 16,
        );
      
      case 'seafood':
        return Icon(
          Icons.set_meal,
          color: iconColor,
          size: 16,
        );
      
      case 'italian':
        return Icon(
          Icons.local_pizza,
          color: iconColor,
          size: 16,
        );
      
      case 'japanese':
        return Icon(
          Icons.ramen_dining,
          color: iconColor,
          size: 16,
        );
      
      case 'thai':
        return Icon(
          Icons.soup_kitchen,
          color: iconColor,
          size: 16,
        );
      
      case 'vegetarian':
        return Icon(
          Icons.spa,
          color: iconColor,
          size: 16,
        );
      
      case 'western':
        return Icon(
          Icons.fastfood,
          color: iconColor,
          size: 16,
        );
      
      case 'fast food':
        return Icon(
          Icons.lunch_dining,
          color: iconColor,
          size: 16,
        );
      
      case 'desserts':
        return Icon(
          Icons.cake,
          color: iconColor,
          size: 16,
        );
      
      case 'cafe':
        return Icon(
          Icons.coffee,
          color: iconColor,
          size: 16,
        );
      
      default:
        return Icon(
          Icons.restaurant,
          color: iconColor,
          size: 16,
        );
    }
  }
}