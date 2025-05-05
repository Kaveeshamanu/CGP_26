// lib/bloc/review/review_bloc.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Part 1: Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class ReviewSubmit extends ReviewEvent {
  final Map<String, dynamic> reviewData;
  final List<File> images;

  const ReviewSubmit({
    required this.reviewData,
    required this.images,
  });

  @override
  List<Object> get props => [reviewData, images];
}

class ReviewUpdate extends ReviewEvent {
  final String reviewId;
  final Map<String, dynamic> reviewData;
  final List<File> newImages;
  final List<String> existingImageUrls;

  const ReviewUpdate({
    required this.reviewId,
    required this.reviewData,
    required this.newImages,
    required this.existingImageUrls,
  });

  @override
  List<Object> get props =>
      [reviewId, reviewData, newImages, existingImageUrls];
}

class ReviewLoad extends ReviewEvent {
  final String entityId;
  final String entityType;

  const ReviewLoad({
    required this.entityId,
    required this.entityType,
  });

  @override
  List<Object> get props => [entityId, entityType];
}

class ReviewDelete extends ReviewEvent {
  final String reviewId;

  const ReviewDelete({
    required this.reviewId,
  });

  @override
  List<Object> get props => [reviewId];
}

// Part 2: States
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSuccess extends ReviewState {
  final Map<String, dynamic> review;

  const ReviewSuccess(this.review);

  @override
  List<Object> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}

class ReviewLoaded extends ReviewState {
  final List<Map<String, dynamic>> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

// Part 3: Bloc
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  // In a real app, you'd inject repositories or services here

  ReviewBloc() : super(ReviewInitial()) {
    on<ReviewSubmit>(_onReviewSubmit);
    on<ReviewUpdate>(_onReviewUpdate);
    on<ReviewLoad>(_onReviewLoad);
    on<ReviewDelete>(_onReviewDelete);
  }

  Future<void> _onReviewSubmit(
    ReviewSubmit event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      // In a real app, you would call your API service here
      // to upload the review and images

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful review submission
      final newReviewId = 'review-${DateTime.now().millisecondsSinceEpoch}';
      final imageUrls = event.images.isNotEmpty
          ? List.generate(
              event.images.length,
              (index) => 'https://example.com/image/$newReviewId-$index.jpg',
            )
          : <String>[];

      final review = {
        'id': newReviewId,
        ...event.reviewData,
        'imageUrls': imageUrls,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      emit(ReviewSuccess(review));
    } catch (e) {
      emit(ReviewError('Failed to submit review: $e'));
    }
  }

  Future<void> _onReviewUpdate(
    ReviewUpdate event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      // In a real app, you would call your API service here
      // to update the review and handle image uploads/deletions

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful review update
      // For new images, generate fake URLs
      final newImageUrls = event.newImages.isNotEmpty
          ? List.generate(
              event.newImages.length,
              (index) =>
                  'https://example.com/image/${event.reviewId}-new-$index.jpg',
            )
          : <String>[];

      final allImageUrls = [...event.existingImageUrls, ...newImageUrls];

      final review = {
        'id': event.reviewId,
        ...event.reviewData,
        'imageUrls': allImageUrls,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      emit(ReviewSuccess(review));
    } catch (e) {
      emit(ReviewError('Failed to update review: $e'));
    }
  }

  Future<void> _onReviewLoad(
    ReviewLoad event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      // In a real app, you would call your API service here
      // to fetch reviews for the entity

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock reviews data
      final reviews = _getMockReviews(event.entityId, event.entityType);

      emit(ReviewLoaded(reviews));
    } catch (e) {
      emit(ReviewError('Failed to load reviews: $e'));
    }
  }

  Future<void> _onReviewDelete(
    ReviewDelete event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      // In a real app, you would call your API service here
      // to delete the review

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would return the updated reviews list
      // Here we'll just signal success
      emit(ReviewSuccess({'id': event.reviewId, 'deleted': true}));
    } catch (e) {
      emit(ReviewError('Failed to delete review: $e'));
    }
  }

  // Helper method for generating mock reviews
  List<Map<String, dynamic>> _getMockReviews(
      String entityId, String entityType) {
    // Generate some mock reviews
    return List.generate(
      5,
      (index) {
        final rating = 3.0 + (index % 3);
        return {
          'id': 'review-$entityId-$index',
          'entityId': entityId,
          'entityType': entityType,
          'userId': 'user-$index',
          'userName': 'User $index',
          'userPhoto':
              index % 3 == 0 ? null : 'https://i.pravatar.cc/150?img=$index',
          'title': 'Great $entityType experience #$index',
          'review':
              'This is a detailed review of my experience with this $entityType. Overall it was ${rating > 4 ? 'excellent' : 'good'}.',
          'rating': rating,
          'recommended': rating > 3.5,
          'visitDate': DateTime.now()
              .subtract(Duration(days: index * 10))
              .toIso8601String(),
          'imageUrls': index % 2 == 0
              ? List.generate(
                  index % 3 + 1,
                  (i) =>
                      'https://picsum.photos/500/300?random=${index * 3 + i}',
                )
              : [],
          'categoryRatings': {
            'Cleanliness': rating - 0.5,
            'Location': rating + 0.5,
            'Service': rating,
            'Value': rating - 0.5,
          },
          'createdAt': DateTime.now()
              .subtract(Duration(days: index * 5))
              .toIso8601String(),
          'updatedAt': DateTime.now()
              .subtract(Duration(days: index * 2))
              .toIso8601String(),
          'helpfulCount': index * 3,
        };
      },
    );
  }
}
