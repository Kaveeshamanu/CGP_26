import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Custom bottom navigation bar for the Taprobana Trails app
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final bool showLabels;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final double iconSize;
  final bool showNotificationBadge;
  final int notificationCount;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.iconSize = 24.0,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Default colors based on theme
    final bgColor = backgroundColor ??
        (isDarkMode ? Theme.of(context).cardColor : Colors.white);

    final selectedColor = selectedItemColor ?? Theme.of(context).primaryColor;
    final unselectedColor =
        unselectedItemColor ?? (isDarkMode ? Colors.white60 : Colors.black54);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Explore',
                index: 0,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Discover',
                index: 1,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
                index: 2,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                context: context,
                icon: FontAwesomeIcons.clipboard,
                activeIcon: FontAwesomeIcons.solidClipboard,
                label: 'Itinerary',
                index: 3,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 4,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                showBadge: showNotificationBadge,
                badgeCount: notificationCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color selectedColor,
    required Color unselectedColor,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: iconSize,
              ),
              if (showBadge && badgeCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Since NavigationBloc, NavigationState are custom classes that you need to implement,
// I've created simplified versions here. Replace with your actual implementations.
class NavigationState {
  final int index;
  final int notificationCount;

  const NavigationState({
    this.index = 0,
    this.notificationCount = 0,
  });
}

class NavigationEvent {}

class NavigationRequested extends NavigationEvent {
  final int index;

  NavigationRequested(this.index);
}

class NavigationBloc {
  void add(NavigationEvent event) {
    // Your navigation logic here
  }
}

/// A bloc-integrated version of the bottom navigation
class BlocBottomNav extends StatelessWidget {
  final bool showLabels;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final double iconSize;

  const BlocBottomNav({
    super.key,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Since we don't have a real BlocBuilder, we'll use a simple approach
    // You should replace this with your actual BlocBuilder implementation

    final navigationState = NavigationState();

    return BottomNav(
      currentIndex: navigationState.index,
      onItemTapped: (index) {
        // Dispatch navigation event to the bloc
        // Implement your actual context.read<NavigationBloc>().add(...) here
      },
      showLabels: showLabels,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor:
          unselectedItemColor, // Fixed: changed from unselectedColor to unselectedItemColor
      elevation: elevation,
      iconSize: iconSize,
      showNotificationBadge: true,
      notificationCount: navigationState.notificationCount,
    );
  }
}

/// A curved bottom navigation with a floating effect
class CurvedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CurvedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Default colors based on theme
    final bgColor = backgroundColor ??
        (isDarkMode ? Theme.of(context).cardColor : Colors.white);

    final selectedColor = selectedItemColor ?? Theme.of(context).primaryColor;
    final unselectedColor =
        unselectedItemColor ?? (isDarkMode ? Colors.white60 : Colors.black54);

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            index: 0,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _buildNavButton(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            index: 1,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _buildNavButton(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            index: 2,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _buildNavButton(
            icon: FontAwesomeIcons.clipboard,
            activeIcon: FontAwesomeIcons.solidClipboard,
            index: 3,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _buildNavButton(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            index: 4,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16.0 : 12.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: isActive ? selectedColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 28,
          color: isActive ? selectedColor : unselectedColor,
        ),
      ),
    );
  }
}
