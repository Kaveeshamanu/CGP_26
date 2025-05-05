// lib/bloc/forum/forum_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Part 1: Events
abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class ForumThreadsRequested extends ForumEvent {
  final String? category;
  final String? searchQuery;

  const ForumThreadsRequested({
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, searchQuery];
}

class ForumThreadUpvote extends ForumEvent {
  final String threadId;
  final bool isUpvoting;

  const ForumThreadUpvote({
    required this.threadId,
    required this.isUpvoting,
  });

  @override
  List<Object> get props => [threadId, isUpvoting];
}

class ForumThreadSave extends ForumEvent {
  final String threadId;
  final bool isSaving;

  const ForumThreadSave({
    required this.threadId,
    required this.isSaving,
  });

  @override
  List<Object> get props => [threadId, isSaving];
}

class ForumThreadDetailsRequested extends ForumEvent {
  final String threadId;

  const ForumThreadDetailsRequested({
    required this.threadId,
  });

  @override
  List<Object> get props => [threadId];
}

class ForumAddComment extends ForumEvent {
  final String threadId;
  final String content;
  final String? parentCommentId;

  const ForumAddComment({
    required this.threadId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [threadId, content, parentCommentId];
}

class ForumCreateThread extends ForumEvent {
  final String title;
  final String content;
  final String? category;
  final List<String>? tags;
  final List<String>? imagePaths;

  const ForumCreateThread({
    required this.title,
    required this.content,
    this.category,
    this.tags,
    this.imagePaths,
  });

  @override
  List<Object?> get props => [title, content, category, tags, imagePaths];
}

// Part 2: States
abstract class ForumState extends Equatable {
  final List<Map<String, dynamic>> threads;

  const ForumState({
    this.threads = const [],
  });

  @override
  List<Object> get props => [threads];
}

class ForumInitial extends ForumState {
  const ForumInitial() : super();
}

class ForumLoading extends ForumState {
  const ForumLoading({super.threads});
}

class ForumLoaded extends ForumState {
  const ForumLoaded(List<Map<String, dynamic>> threads)
      : super(threads: threads);
}

class ForumError extends ForumState {
  final String message;

  const ForumError(this.message, {super.threads});

  @override
  List<Object> get props => [message, threads];
}

class ForumThreadDetails extends ForumState {
  final Map<String, dynamic> threadDetails;
  final List<Map<String, dynamic>> comments;

  const ForumThreadDetails({
    required this.threadDetails,
    required this.comments,
    super.threads,
  });

  @override
  List<Object> get props => [threadDetails, comments, threads];
}

// Part 3: The Bloc
class ForumBloc extends Bloc<ForumEvent, ForumState> {
  // Typically you'd inject a repository or API service here

  ForumBloc() : super(const ForumInitial()) {
    on<ForumThreadsRequested>(_onThreadsRequested);
    on<ForumThreadUpvote>(_onThreadUpvote);
    on<ForumThreadSave>(_onThreadSave);
    on<ForumThreadDetailsRequested>(_onThreadDetailsRequested);
    on<ForumAddComment>(_onAddComment);
    on<ForumCreateThread>(_onCreateThread);
  }

  Future<void> _onThreadsRequested(
    ForumThreadsRequested event,
    Emitter<ForumState> emit,
  ) async {
    // If we already have threads and are just filtering or searching,
    // we can optimize by not showing a loading state with empty threads
    final currentThreads = state.threads;
    if (currentThreads.isNotEmpty) {
      emit(ForumLoading(threads: currentThreads));
    } else {
      emit(const ForumLoading());
    }

    try {
      // In a real app, you would fetch data from an API
      // final response = await forumRepository.getThreads(
      //   category: event.category,
      //   searchQuery: event.searchQuery,
      // );

      // For demonstration, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));
      final threads = _getMockThreads(
          category: event.category, searchQuery: event.searchQuery);

      emit(ForumLoaded(threads));
    } catch (e) {
      emit(ForumError('Failed to load threads: $e', threads: currentThreads));
    }
  }

  Future<void> _onThreadUpvote(
    ForumThreadUpvote event,
    Emitter<ForumState> emit,
  ) async {
    // Handle upvoting a thread
    final currentState = state;

    // Update the thread in the list
    List<Map<String, dynamic>> updatedThreads = [];
    if (currentState is ForumLoaded || currentState is ForumLoading) {
      updatedThreads = currentState.threads.map((thread) {
        if (thread['id'] == event.threadId) {
          final currentUpvotes = thread['upvotes'] as int? ?? 0;
          return {
            ...thread,
            'upvotes':
                event.isUpvoting ? currentUpvotes + 1 : currentUpvotes - 1,
            'isUpvoted': event.isUpvoting,
          };
        }
        return thread;
      }).toList();

      // If the state is a thread details state, also update the thread details
      if (currentState is ForumThreadDetails) {
        final threadDetails = currentState.threadDetails;
        if (threadDetails['id'] == event.threadId) {
          final currentUpvotes = threadDetails['upvotes'] as int? ?? 0;
          final updatedThreadDetails = {
            ...threadDetails,
            'upvotes':
                event.isUpvoting ? currentUpvotes + 1 : currentUpvotes - 1,
            'isUpvoted': event.isUpvoting,
          };

          emit(ForumThreadDetails(
            threadDetails: updatedThreadDetails,
            comments: currentState.comments,
            threads: updatedThreads,
          ));
          return;
        }
      }

      // Emit updated threads
      if (currentState is ForumLoaded) {
        emit(ForumLoaded(updatedThreads));
      } else if (currentState is ForumLoading) {
        emit(ForumLoading(threads: updatedThreads));
      }
    }

    // In a real app, you would call the API to persist the upvote
    // try {
    //   await forumRepository.upvoteThread(event.threadId, event.isUpvoting);
    // } catch (e) {
    //   // Handle error - perhaps revert the optimistic update
    // }
  }

  Future<void> _onThreadSave(
    ForumThreadSave event,
    Emitter<ForumState> emit,
  ) async {
    // Handle saving a thread
    final currentState = state;

    // Update the thread in the list
    if (currentState is ForumLoaded || currentState is ForumLoading) {
      final updatedThreads = currentState.threads.map((thread) {
        if (thread['id'] == event.threadId) {
          return {
            ...thread,
            'isSaved': event.isSaving,
          };
        }
        return thread;
      }).toList();

      // If the state is a thread details state, also update the thread details
      if (currentState is ForumThreadDetails) {
        final threadDetails = currentState.threadDetails;
        if (threadDetails['id'] == event.threadId) {
          final updatedThreadDetails = {
            ...threadDetails,
            'isSaved': event.isSaving,
          };

          emit(ForumThreadDetails(
            threadDetails: updatedThreadDetails,
            comments: currentState.comments,
            threads: updatedThreads,
          ));
          return;
        }
      }

      // Emit updated threads
      if (currentState is ForumLoaded) {
        emit(ForumLoaded(updatedThreads));
      } else if (currentState is ForumLoading) {
        emit(ForumLoading(threads: updatedThreads));
      }
    }

    // In a real app, you would call the API to persist the saved state
    // try {
    //   await forumRepository.saveThread(event.threadId, event.isSaving);
    // } catch (e) {
    //   // Handle error - perhaps revert the optimistic update
    // }
  }

  Future<void> _onThreadDetailsRequested(
    ForumThreadDetailsRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());

    try {
      // In a real app, you would fetch thread details from an API
      // final response = await forumRepository.getThreadDetails(event.threadId);

      // For demonstration, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));

      // Find the thread in the current state if possible
      Map<String, dynamic>? threadDetails;
      final currentThreads = state.threads;
      if (currentThreads.isNotEmpty) {
        threadDetails = currentThreads.firstWhere(
          (thread) => thread['id'] == event.threadId,
          orElse: () => _getMockThreadDetails(event.threadId),
        );
      } else {
        threadDetails = _getMockThreadDetails(event.threadId);
      }

      final comments = _getMockComments(event.threadId);

      emit(ForumThreadDetails(
        threadDetails: threadDetails,
        comments: comments,
        threads: currentThreads,
      ));
    } catch (e) {
      emit(ForumError('Failed to load thread details: $e'));
    }
  }

  Future<void> _onAddComment(
    ForumAddComment event,
    Emitter<ForumState> emit,
  ) async {
    // Only handle if we're in a thread details state
    if (state is ForumThreadDetails) {
      final currentState = state as ForumThreadDetails;

      // Create a new mock comment
      final newComment = {
        'id': 'comment-${DateTime.now().millisecondsSinceEpoch}',
        'threadId': event.threadId,
        'content': event.content,
        'authorId':
            'current-user', // In a real app, this would be the user's ID
        'authorName':
            'Current User', // In a real app, this would be the user's name
        'authorPhotoUrl':
            null, // In a real app, this would be the user's photo URL
        'createdAt': DateTime.now().toIso8601String(),
        'parentId': event.parentCommentId,
        'upvotes': 0,
        'isUpvoted': false,
      };

      // Add the new comment to the list
      final updatedComments = [...currentState.comments, newComment];

      // Update thread detail's comment count
      final updatedThreadDetails = {
        ...currentState.threadDetails,
        'commentCount':
            (currentState.threadDetails['commentCount'] as int? ?? 0) + 1,
      };

      // Also update the thread in the list if it exists
      final currentThreads = currentState.threads;
      final updatedThreads = currentThreads.map((thread) {
        if (thread['id'] == event.threadId) {
          return {
            ...thread,
            'commentCount': (thread['commentCount'] as int? ?? 0) + 1,
          };
        }
        return thread;
      }).toList();

      emit(ForumThreadDetails(
        threadDetails: updatedThreadDetails,
        comments: updatedComments,
        threads: updatedThreads,
      ));

      // In a real app, you would call the API to add the comment
      // try {
      //   await forumRepository.addComment(
      //     event.threadId,
      //     event.content,
      //     event.parentCommentId,
      //   );
      // } catch (e) {
      //   // Handle error - perhaps revert the optimistic update
      // }
    }
  }

  Future<void> _onCreateThread(
    ForumCreateThread event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());

    try {
      // In a real app, you would call the API to create a thread
      // final newThread = await forumRepository.createThread(
      //   title: event.title,
      //   content: event.content,
      //   category: event.category,
      //   tags: event.tags,
      //   imagePaths: event.imagePaths,
      // );

      // For demonstration, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));

      // Create a new mock thread
      final newThread = {
        'id': 'thread-${DateTime.now().millisecondsSinceEpoch}',
        'title': event.title,
        'content': event.content,
        'authorId':
            'current-user', // In a real app, this would be the user's ID
        'authorName':
            'Current User', // In a real app, this would be the user's name
        'authorPhotoUrl':
            null, // In a real app, this would be the user's photo URL
        'category': event.category,
        'tags': event.tags ?? [],
        'imageUrls': event.imagePaths ??
            [], // In a real app, these would be uploaded and the URLs returned
        'createdAt': DateTime.now().toIso8601String(),
        'upvotes': 0,
        'commentCount': 0,
        'isUpvoted': false,
        'isSaved': false,
      };

      // Add the new thread to the list
      final currentThreads = state.threads;
      final updatedThreads = [newThread, ...currentThreads];

      emit(ForumLoaded(updatedThreads));

      // After creating the thread, you might want to navigate to its details
      // This would typically be handled in the UI layer, not the BLoC
    } catch (e) {
      emit(ForumError('Failed to create thread: $e'));
    }
  }

  // Helper methods to generate mock data
  List<Map<String, dynamic>> _getMockThreads(
      {String? category, String? searchQuery}) {
    // Generate some mock threads
    final threads = List.generate(
      10,
      (index) => {
        'id': 'thread-$index',
        'title': 'Discussion Thread #$index about ${category ?? 'Travel'}',
        'content':
            'This is the content of discussion thread #$index. It contains some text about ${category ?? 'travel'} topics.',
        'authorId': 'user-$index',
        'authorName': 'User $index',
        'authorPhotoUrl':
            index % 3 == 0 ? null : 'https://i.pravatar.cc/150?img=$index',
        'category': category ?? _getRandomCategory(),
        'tags': ['travel', 'discussion', 'thread-$index'],
        'imageUrls': index % 4 == 0
            ? []
            : List.generate(
                index % 3 + 1,
                (i) => 'https://picsum.photos/500/300?random=${index * 3 + i}',
              ),
        'createdAt':
            DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        'upvotes': index * 5,
        'commentCount': index * 3,
        'isUpvoted': false,
        'isSaved': false,
      },
    );

    // Filter by category if provided
    final filteredThreads = category == null
        ? threads
        : threads.where((thread) => thread['category'] == category).toList();

    // Filter by search query if provided
    final searchResults = searchQuery == null || searchQuery.isEmpty
        ? filteredThreads
        : filteredThreads.where((thread) {
            final title = thread['title'] as String;
            final content = thread['content'] as String;
            return title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                content.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

    return searchResults;
  }

  String _getRandomCategory() {
    const categories = [
      'Destinations',
      'Accommodation',
      'Transportation',
      'Food & Dining',
      'Activities',
      'Tips & Advice',
      'Meetups',
    ];
    return categories[DateTime.now().millisecond % categories.length];
  }

  Map<String, dynamic> _getMockThreadDetails(String threadId) {
    // In a real app, you would fetch the thread details from an API
    // For now, we'll create a mock thread
    final index = int.tryParse(threadId.split('-').last) ?? 0;
    return {
      'id': threadId,
      'title': 'Discussion Thread #$index Details',
      'content':
          'This is the detailed content of discussion thread #$index. It contains much more text about travel topics and experiences.',
      'authorId': 'user-$index',
      'authorName': 'User $index',
      'authorPhotoUrl':
          index % 3 == 0 ? null : 'https://i.pravatar.cc/150?img=$index',
      'category': _getRandomCategory(),
      'tags': ['travel', 'discussion', 'thread-$index', 'details'],
      'imageUrls': index % 4 == 0
          ? []
          : List.generate(
              index % 3 + 1,
              (i) => 'https://picsum.photos/500/300?random=${index * 3 + i}',
            ),
      'createdAt':
          DateTime.now().subtract(Duration(days: index)).toIso8601String(),
      'upvotes': index * 5,
      'commentCount': index * 3,
      'isUpvoted': false,
      'isSaved': false,
    };
  }

  List<Map<String, dynamic>> _getMockComments(String threadId) {
    // Generate some mock comments for the thread
    final index = int.tryParse(threadId.split('-').last) ?? 0;
    final commentCount = index * 3;

    return List.generate(
      commentCount,
      (i) => {
        'id': 'comment-$i-$threadId',
        'threadId': threadId,
        'content':
            'This is comment #$i on thread $threadId. It contains some text discussing the topic.',
        'authorId': 'user-${i + 100}',
        'authorName': 'Commenter ${i + 100}',
        'authorPhotoUrl':
            i % 3 == 0 ? null : 'https://i.pravatar.cc/150?img=${i + 100}',
        'createdAt':
            DateTime.now().subtract(Duration(hours: i * 2)).toIso8601String(),
        'parentId': i % 4 == 0 && i > 0
            ? 'comment-${i - 1}-$threadId'
            : null, // Some comments are replies
        'upvotes': i,
        'isUpvoted': false,
      },
    );
  }
}
