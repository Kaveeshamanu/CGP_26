import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A custom app bar for the Taprobana Trails app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final bool centerTitle;
  final bool showLogo;
  final bool showElevation;
  final double elevation;
  final double height;
  final Function()? onBackPressed;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.centerTitle = true,
    this.showLogo = false,
    this.showElevation = true,
    this.elevation = 2.0,
    this.height = kToolbarHeight,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(bottom == null ? height : height + bottom!.preferredSize.height);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = backgroundColor ?? 
        (isDarkMode 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Theme.of(context).primaryColor);
    
    final txtColor = textColor ?? 
        (isDarkMode || (backgroundColor != null && backgroundColor != Theme.of(context).primaryColor)
          ? Theme.of(context).textTheme.titleLarge?.color 
          : Colors.white);
    
    final statusBarBrightness = isDarkMode 
        ? Brightness.dark 
        : (bgColor.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light);
    
    return AppBar(
      title: showLogo 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/app_logo.svg',
                  height: 24,
                  color: txtColor,
                ),
                const SizedBox(width: 8),
                Text(title),
              ],
            )
          : Text(title),
      backgroundColor: bgColor,
      foregroundColor: txtColor,
      centerTitle: centerTitle,
      elevation: showElevation ? elevation : 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarBrightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        statusBarBrightness: statusBarBrightness,
      ),
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }
}

/// A transparent version of CustomAppBar for overlaying on content
class TransparentAppBar extends CustomAppBar {
  const TransparentAppBar({
    super.key,
    super.title = '',
    super.showBackButton = true,
    super.actions,
    Color super.textColor = Colors.white,
    super.centerTitle,
    super.onBackPressed,
  }) : super(
    backgroundColor: Colors.transparent,
    showElevation: false,
  );
}

/// A collapsible app bar with an image background
class CollapsibleImageAppBar extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double expandedHeight;
  final Widget? content;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? actionButton;
  final Color? textColor;
  final Function()? onBackPressed;

  const CollapsibleImageAppBar({
    super.key,
    required this.title,
    required this.imageUrl,
    this.expandedHeight = 200.0,
    this.content,
    this.showBackButton = true,
    this.actions,
    this.actionButton,
    this.textColor = Colors.white,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image with gradient overlay
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.error_outline, color: Colors.white, size: 40),
                ),
              ),
            ),
            // Gradient for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            // Optional content
            if (content != null)
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: content!,
              ),
            // Optional action button (like favorite)
            if (actionButton != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: actionButton!,
              ),
          ],
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }
}

/// A search app bar with integrated search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final Function(String) onSearch;
  final Function()? onBackPressed;
  final bool showFilterButton;
  final Function()? onFilterPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;

  const SearchAppBar({
    super.key,
    required this.title,
    this.hintText = 'Search...',
    required this.onSearch,
    this.onBackPressed,
    this.showFilterButton = false,
    this.onFilterPressed,
    this.backgroundColor,
    this.textColor,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchController.clear();
        widget.onSearch('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = widget.backgroundColor ?? 
        (isDarkMode 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Theme.of(context).primaryColor);
    
    final txtColor = widget.textColor ?? 
        (isDarkMode || (widget.backgroundColor != null && widget.backgroundColor != Theme.of(context).primaryColor)
          ? Theme.of(context).textTheme.titleLarge?.color 
          : Colors.white);

    return AppBar(
      title: _isSearchMode
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: txtColor?.withOpacity(0.7)),
                border: InputBorder.none,
              ),
              style: TextStyle(color: txtColor),
              onChanged: widget.onSearch,
            )
          : Text(widget.title),
      backgroundColor: bgColor,
      foregroundColor: txtColor,
      leading: IconButton(
        icon: Icon(_isSearchMode ? Icons.arrow_back : Icons.arrow_back),
        onPressed: _isSearchMode
            ? _toggleSearchMode
            : (widget.onBackPressed ?? () => Navigator.of(context).pop()),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearchMode ? Icons.clear : Icons.search),
          onPressed: _isSearchMode
              ? () {
                  _searchController.clear();
                  widget.onSearch('');
                }
              : _toggleSearchMode,
        ),
        if (widget.showFilterButton && !_isSearchMode)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: widget.onFilterPressed,
          ),
      ],
    );
  }
}