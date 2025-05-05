import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taprobana_trails/bloc/forum/forum_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../data/models/user.dart';
import '../../core/utils/connectivity.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/buttons.dart';
import 'widgets/discussion_thread.dart';

class ForumScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ForumScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late ForumBloc _forumBloc;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _currentQuery = '';
  int _selectedCategoryIndex = 0;

  final List<String> _forumCategories = [
    'All',
    'Destinations',
    'Accommodation',
    'Transportation',
    'Food & Dining',
    'Activities',
    'Tips & Advice',
    'Meetups',
  ];

  final List<IconData> _categoryIcons = [
    Icons.forum,
    Icons.place,
    Icons.hotel,
    Icons.directions_bus,
    Icons.restaurant,
    Icons.local_activity,
    Icons.lightbulb,
    Icons.people,
  ];

  @override
  void initState() {
    super.initState();
    _forumBloc = BlocProvider.of<ForumBloc>(context);
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    // Set initial category if provided
    if (widget.categoryId != null) {
      final categoryIndex = _forumCategories.indexWhere(
        (category) =>
            category.toLowerCase() == widget.categoryName?.toLowerCase(),
      );
      if (categoryIndex != -1) {
        _selectedCategoryIndex = categoryIndex;
      }
    }

    // Load initial data
    _loadForumThreads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadForumThreads() {
    final category = _selectedCategoryIndex == 0
        ? null
        : _forumCategories[_selectedCategoryIndex];

    _forumBloc.add(ForumThreadsRequested(
      category: category,
      searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
    ));
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _currentQuery = '';
        _loadForumThreads();
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _currentQuery = query;
    });
    _loadForumThreads();
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    _loadForumThreads();
  }

  void _createNewThread() {
    Navigator.pushNamed(
      context,
      '/create_thread',
      arguments: {
        'categoryId': _selectedCategoryIndex == 0
            ? null
            : _forumCategories[_selectedCategoryIndex],
      },
    ).then((_) => _loadForumThreads());
  }

  void _refreshForum() {
    _loadForumThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategorySelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThreadList(sortBy: 'recent'),
                _buildThreadList(sortBy: 'popular'),
                _buildThreadList(sortBy: 'unanswered'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewThread,
        tooltip: 'Create New Thread',
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return _isSearchActive
        ? SearchAppBar(
            title: 'Forum',
            hintText: 'Search discussions...',
            onSearch: _performSearch,
            onBackPressed: _toggleSearch,
          )
        : CustomAppBar(
            title: widget.categoryName ?? 'Community Forum',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshForum,
              ),
            ],
          );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: _forumCategories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _selectCategory(index),
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Icon(
                      _categoryIcons[index],
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  _forumCategories[index],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3.0,
        tabs: const [
          Tab(text: 'Recent'),
          Tab(text: 'Popular'),
          Tab(text: 'Unanswered'),
        ],
        onTap: (index) {
          // Reload data when tab changes
          _loadForumThreads();
        },
      ),
    );
  }

  Widget _buildThreadList({required String sortBy}) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        if (state is ForumInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ForumLoading && state.threads.isEmpty) {
          return ContentLoader(
            itemCount: 5,
            showImage: false,
            height: 120.0,
          );
        } else if (state is ForumError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48.0,
                  color: Colors.red,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Error: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _refreshForum,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Get threads from state and sort them
        final threads = state is ForumLoaded
            ? _sortThreads(state.threads, sortBy)
            : state is ForumLoading
                ? _sortThreads(state.threads, sortBy)
                : [];

        if (threads.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refreshForum();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: threads.length + (state is ForumLoading ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 32.0),
            itemBuilder: (context, index) {
              if (index == threads.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final thread = threads[index];
              return DiscussionThread(
                threadData: thread,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/thread_details',
                    arguments: {'threadId': thread['id']},
                  ).then((_) => _loadForumThreads());
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    IconData iconData;
    String message;

    if (_currentQuery.isNotEmpty) {
      iconData = Icons.search_off;
      message = 'No threads found matching "$_currentQuery"';
    } else if (_selectedCategoryIndex != 0) {
      iconData = _categoryIcons[_selectedCategoryIndex];
      message = 'No threads in ${_forumCategories[_selectedCategoryIndex]} yet';
    } else {
      iconData = Icons.forum_outlined;
      message = 'No discussions yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 64.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          PrimaryButton(
            text: 'Start a Discussion',
            icon: Icons.add,
            fullWidth: false,
            onPressed: _createNewThread,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _sortThreads(
    List<Map<String, dynamic>> threads,
    String sortBy,
  ) {
    final filteredThreads = List<Map<String, dynamic>>.from(threads);

    switch (sortBy) {
      case 'recent':
        filteredThreads.sort((a, b) {
          final aDate = DateTime.parse(a['createdAt'] as String);
          final bDate = DateTime.parse(b['createdAt'] as String);
          return bDate.compareTo(aDate);
        });
        break;
      case 'popular':
        filteredThreads.sort((a, b) {
          final aVotes = a['upvotes'] as int? ?? 0;
          final bVotes = b['upvotes'] as int? ?? 0;
          if (bVotes != aVotes) {
            return bVotes.compareTo(aVotes);
          }
          final aComments = a['commentCount'] as int? ?? 0;
          final bComments = b['commentCount'] as int? ?? 0;
          return bComments.compareTo(aComments);
        });
        break;
      case 'unanswered':
        return filteredThreads
            .where((thread) => (thread['commentCount'] as int? ?? 0) == 0)
            .toList()
          ..sort((a, b) {
            final aDate = DateTime.parse(a['createdAt'] as String);
            final bDate = DateTime.parse(b['createdAt'] as String);
            return bDate.compareTo(aDate);
          });
    }

    return filteredThreads;
  }
}
