import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../data/models/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/buttons.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_option.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load user data
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    // In a real app, this would load from the auth bloc
    // For now, we'll simulate loading user data
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _user = User(
        id: 'user123',
        name: 'Ranil Jayawardena',
        email: 'ranil@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        phoneNumber: '+94 77 123 4567',
        memberSince: DateTime(2023, 5, 10),
        travelPoints: 850,
        completedTrips: 5,
        wishlistedDestinations: 12,
        reviewsCount: 8,
        badges: [
          Badge(
            id: 'badge1',
            name: 'Explorer',
            description: 'Visited 5 destinations',
            iconUrl: 'assets/images/badges/explorer.png',
            dateEarned: DateTime(2023, 6, 15),
          ),
          Badge(
            id: 'badge2',
            name: 'Reviewer',
            description: 'Posted 5+ reviews',
            iconUrl: 'assets/images/badges/reviewer.png',
            dateEarned: DateTime(2023, 8, 22),
          ),
        ],
      );
      _isLoading = false;
    });
  }

  Future<void> _updateProfilePicture() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isLoading = true;
      });

      // In a real app, this would upload the image to storage
      // and update the user's profile
      await Future.delayed(const Duration(seconds: 1));

      // Simulate update success
      setState(() {
        // _user would be updated with the new image URL in a real app
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _editProfile() {
    Navigator.pushNamed(context, '/edit_profile');
  }

  void _shareProfile() {
    if (_user == null) return;

    Share.share(
      'Check out my travels on Taprobana Trails! I\'ve visited ${_user!.completedTrips} destinations and earned ${_user!.travelPoints} points. Join me on https://taprobanatrails.com',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Profile',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: null, // Will be set in the returned widget
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          if (state is AuthUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
          }

          return Stack(
            children: [
              _buildProfileContent(),
              if (_isLoading)
                const Center(
                  child: CircularProgressLoader(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_user == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          ProfileHeader(
            user: _user!,
            onEditProfileTap: _editProfile,
            onProfileImageTap: _updateProfilePicture,
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Trips'),
                Tab(text: 'Badges'),
              ],
            ),
          ),

          // Tab content
          SizedBox(
            height: screenHeight * 0.6, // Adjust based on content
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTripsTab(),
                _buildBadgesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              _buildStatCard(
                icon: Icons.place_outlined,
                title: 'Destinations',
                value: _user!.completedTrips.toString(),
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.star_outline,
                title: 'Reviews',
                value: _user!.reviewsCount.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.favorite_border,
                title: 'Wishlisted',
                value: _user!.wishlistedDestinations.toString(),
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.emoji_events_outlined,
                title: 'Points',
                value: _user!.travelPoints.toString(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Profile information
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: _user!.email,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: _user!.phoneNumber ?? 'Not provided',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.calendar_today_outlined,
            title: 'Member Since',
            value: _formatDate(_user!.memberSince),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareProfile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripsTab() {
    if (_user!.completedTrips == 0) {
      return _buildEmptyState(
        icon: Icons.flight_takeoff,
        title: 'No trips yet',
        message: 'Your completed trips will appear here.',
        actionLabel: 'Start Planning',
        onActionPressed: () {
          Navigator.pushNamed(context, '/destinations');
        },
      );
    }

    // Placeholder content for trips tab
    return Center(
      child: Text(
        'Trips tab content - would show ${_user!.completedTrips} trips',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBadgesTab() {
    if (_user!.badges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'No badges yet',
        message: 'Complete activities to earn badges and rewards.',
        actionLabel: 'View Available Badges',
        onActionPressed: () {
          // Navigate to badges screen
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _user!.badges.length,
      itemBuilder: (context, index) {
        final badge = _user!.badges[index];
        return _buildBadgeCard(badge);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Card(
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
                children: [
                  Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              badge.iconUrl,
              width: 64,
              height: 64,
              errorBuilder: (ctx, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Earned: ${_formatDate(badge.dateEarned)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

extension on Badge {
  DateTime get dateEarned => DateTime.now();

  String get name => "";

  String get description => "";

  String get iconUrl => "";
}
