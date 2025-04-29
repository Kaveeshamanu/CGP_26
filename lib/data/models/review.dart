import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

/// The type of entity a review can be associated with.
enum ReviewEntityType {
  accommodation,
  restaurant,
  destination,
  activity,
  transportation,
}

/// Review model for storing user reviews.
@JsonSerializable()
class Review extends Equatable {
  /// The unique identifier of the review.
  final String id;
  
  /// The ID of the entity being reviewed.
  final String entityId;
  
  /// The type of entity being reviewed.
  final ReviewEntityType entityType;
  
  /// The ID of the user who wrote the review.
  final String userId;
  
  /// The name of the user who wrote the review.
  final String userName;
  
  /// The profile photo URL of the user who wrote the review.
  final String? userPhotoUrl;
  
  /// The rating given (0-5 scale).
  final double rating;
  
  /// The title of the review.
  final String title;
  
  /// The content of the review.
  final String content;
  
  /// The list of image URLs attached to the review.
  final List<String>? images;
  
  /// The timestamp when the review was created.
  final DateTime createdAt;
  
  /// The timestamp when the review was last updated.
  final DateTime updatedAt;
  
  /// The tags/categories associated with the review.
  final List<String>? tags;
  
  /// The specific aspects ratings (e.g., cleanliness: 4.5, service: 5.0).
  final Map<String, double>? aspectRatings;
  
  /// The trip type (e.g., business, family, couple).
  final String? tripType;
  
  /// The date of stay/visit.
  final DateTime? visitDate;
  
  /// The helpful votes count.
  final int helpfulVotes;
  
  /// The unhelpful votes count.
  final int unhelpfulVotes;
  
  /// The reply to the review from the entity owner.
  final Map<String, dynamic>? ownerReply;
  
  /// Whether the review is verified.
  final bool isVerified;
  
  /// Creates a new Review.
  const Review({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.title,
    required this.content,
    this.images,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
    this.aspectRatings,
    this.tripType,
    this.visitDate,
    this.helpfulVotes = 0,
    this.unhelpfulVotes = 0,
    this.ownerReply,
    this.isVerified = false,
  });
  
  /// Factory constructor that creates a [Review] from JSON.
  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  
  /// Converts this [Review] to JSON.
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
  
  /// Creates a copy of this [Review] with the given fields replaced with new values.
  Review copyWith({
    String? id,
    String? entityId,
    ReviewEntityType? entityType,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? title,
    String? content,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, double>? aspectRatings,
    String? tripType,
    DateTime? visitDate,
    int? helpfulVotes,
    int? unhelpfulVotes,
    Map<String, dynamic>? ownerReply,
    bool? isVerified,
  }) {
    return Review(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      aspectRatings: aspectRatings ?? this.aspectRatings,
      tripType: tripType ?? this.tripType,
      visitDate: visitDate ?? this.visitDate,
      helpfulVotes: helpfulVotes ?? this.helpfulVotes,
      unhelpfulVotes: unhelpfulVotes ?? this.unhelpfulVotes,
      ownerReply: ownerReply ?? this.ownerReply,
      isVerified: isVerified ?? this.isVerified,
    );
  }
  
  /// Gets the formatted rating as stars.
  String get ratingAsStars {
    final fullStars = rating.floor();
    final halfStar = rating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
    
    return '${'★' * fullStars}${halfStar ? '½' : ''}${'☆' * emptyStars}';
  }
  
  /// Gets the relative time since the review was created.
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
  
  /// Gets the formatted visit date.
  String? get formattedVisitDate {
    if (visitDate == null) return null;
    
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[visitDate!.month - 1]} ${visitDate!.year}';
  }
  
  /// Gets the net helpfulness (helpful votes minus unhelpful votes).
  int get netHelpfulness {
    return helpfulVotes - unhelpfulVotes;
  }
  
  /// Gets whether the review has images.
  bool get hasImages {
    return images != null && images!.isNotEmpty;
  }
  
  /// Gets whether the review has aspect ratings.
  bool get hasAspectRatings {
    return aspectRatings != null && aspectRatings!.isNotEmpty;
  }
  
  /// Gets whether the review has an owner reply.
  bool get hasOwnerReply {
    return ownerReply != null && ownerReply!.isNotEmpty;
  }
  
  /// Gets the average aspect rating if aspect ratings are available.
  double? get averageAspectRating {
    if (!hasAspectRatings) return null;
    
    final total = aspectRatings!.values.reduce((a, b) => a + b);
    return total / aspectRatings!.length;
  }
  
  /// Gets the trip type icon.
  String get tripTypeIcon {
    switch (tripType?.toLowerCase()) {
      case 'business':
        return 'business_center';
      case 'family':
        return 'family_restroom';
      case 'couple':
        return 'favorite';
      case 'friends':
        return 'group';
      case 'solo':
        return 'person';
      default:
        return 'travel_explore';
    }
  }
  
  /// Gets the trip type display text.
  String get tripTypeDisplay {
    if (tripType == null) return 'Traveler';
    
    return '${tripType![0].toUpperCase()}${tripType!.substring(1)} Traveler';
  }
  
  /// Gets a brief content preview (first 100 characters).
  String get briefContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }
  
  /// Gets whether this is a positive review (rating >= 4.0).
  bool get isPositive {
    return rating >= 4.0;
  }
  
  /// Gets whether this is a negative review (rating <= 2.0).
  bool get isNegative {
    return rating <= 2.0;
  }
  
  /// Gets whether this is a neutral review (rating between 2.0 and 4.0).
  bool get isNeutral {
    return rating > 2.0 && rating < 4.0;
  }
  
  /// Gets the owner reply formatted date.
  String? get ownerReplyDate {
    if (!hasOwnerReply || !ownerReply!.containsKey('date')) return null;
    
    final replyDate = ownerReply!['date'] as DateTime?;
    if (replyDate == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(replyDate);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
  
  @override
  List<Object?> get props => [
    id,
    entityId,
    entityType,
    userId,
    userName,
    userPhotoUrl,
    rating,
    title,
    content,
    images,
    createdAt,
    updatedAt,
    tags,
    aspectRatings,
    tripType,
    visitDate,
    helpfulVotes,
    unhelpfulVotes,
    ownerReply,
    isVerified,
  ];
}