// lib/bloc/deals/deals_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Part 1: Events
abstract class DealsEvent extends Equatable {
  const DealsEvent();

  @override
  List<Object?> get props => [];
}

class DealsRequested extends DealsEvent {
  final String? category;
  final String? searchQuery;

  const DealsRequested({
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, searchQuery];
}

class DealDetailsRequested extends DealsEvent {
  final String dealId;

  const DealDetailsRequested({
    required this.dealId,
  });

  @override
  List<Object> get props => [dealId];
}

class DealRedeemed extends DealsEvent {
  final String dealId;

  const DealRedeemed({
    required this.dealId,
  });

  @override
  List<Object> get props => [dealId];
}

class DealSaved extends DealsEvent {
  final String dealId;
  final bool isSaving;

  const DealSaved({
    required this.dealId,
    required this.isSaving,
  });

  @override
  List<Object> get props => [dealId, isSaving];
}

// Part 2: States
abstract class DealsState extends Equatable {
  final List<Map<String, dynamic>> deals;

  const DealsState({
    this.deals = const [],
  });

  @override
  List<Object> get props => [deals];
}

class DealsInitial extends DealsState {
  const DealsInitial() : super();
}

class DealsLoading extends DealsState {
  const DealsLoading({super.deals});
}

class DealsLoaded extends DealsState {
  const DealsLoaded(List<Map<String, dynamic>> deals) : super(deals: deals);
}

class DealsError extends DealsState {
  final String message;

  const DealsError(this.message, {super.deals});

  @override
  List<Object> get props => [message, deals];
}

class DealDetails extends DealsState {
  final Map<String, dynamic> dealDetails;

  const DealDetails({
    required this.dealDetails,
    super.deals,
  });

  @override
  List<Object> get props => [dealDetails, deals];
}

// Part 3: Bloc
class DealsBloc extends Bloc<DealsEvent, DealsState> {
  // In a real app, you would inject repositories or services here

  DealsBloc() : super(const DealsInitial()) {
    on<DealsRequested>(_onDealsRequested);
    on<DealDetailsRequested>(_onDealDetailsRequested);
    on<DealRedeemed>(_onDealRedeemed);
    on<DealSaved>(_onDealSaved);
  }

  Future<void> _onDealsRequested(
    DealsRequested event,
    Emitter<DealsState> emit,
  ) async {
    // If we already have deals and are just filtering or searching,
    // show a loading state with existing deals to prevent flickering
    final currentDeals = state.deals;
    if (currentDeals.isNotEmpty) {
      emit(DealsLoading(deals: currentDeals));
    } else {
      emit(const DealsLoading());
    }

    try {
      // In a real app, you would fetch data from an API
      // final response = await dealsRepository.getDeals(
      //   category: event.category,
      //   searchQuery: event.searchQuery,
      // );

      // For demonstration, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));
      final deals = _getMockDeals(
          category: event.category, searchQuery: event.searchQuery);

      emit(DealsLoaded(deals));
    } catch (e) {
      emit(DealsError('Failed to load deals: $e', deals: currentDeals));
    }
  }

  Future<void> _onDealDetailsRequested(
    DealDetailsRequested event,
    Emitter<DealsState> emit,
  ) async {
    emit(const DealsLoading());

    try {
      // In a real app, you would fetch deal details from an API
      // final response = await dealsRepository.getDealDetails(event.dealId);

      // For demonstration, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));

      // Find the deal in the current state if possible
      Map<String, dynamic>? dealDetails;
      final currentDeals = state.deals;
      if (currentDeals.isNotEmpty) {
        dealDetails = currentDeals.firstWhere(
          (deal) => deal['id'] == event.dealId,
          orElse: () => _getMockDealDetails(event.dealId),
        );
      } else {
        dealDetails = _getMockDealDetails(event.dealId);
      }

      emit(DealDetails(
        dealDetails: dealDetails,
        deals: currentDeals,
      ));
    } catch (e) {
      emit(DealsError('Failed to load deal details: $e'));
    }
  }

  Future<void> _onDealRedeemed(
    DealRedeemed event,
    Emitter<DealsState> emit,
  ) async {
    // Track current state for rollback if needed
    final currentState = state;

    // Update deals list to show as redeemed
    if (currentState is DealsLoaded || currentState is DealsLoading) {
      final updatedDeals = currentState.deals.map((deal) {
        if (deal['id'] == event.dealId) {
          return {
            ...deal,
            'isRedeemed': true,
            'redeemedAt': DateTime.now().toIso8601String(),
          };
        }
        return deal;
      }).toList();

      emit(DealsLoaded(updatedDeals));
    }

    try {
      // In a real app, you would call the API to redeem the deal
      // await dealsRepository.redeemDeal(event.dealId);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Success is already reflected in the state update above
    } catch (e) {
      // On error, revert to previous state
      emit(DealsError('Failed to redeem deal: $e'));

      if (currentState is DealsLoaded) {
        emit(DealsLoaded(currentState.deals));
      } else if (currentState is DealDetails) {
        emit(DealDetails(
          dealDetails: currentState.dealDetails,
          deals: currentState.deals,
        ));
      }
    }
  }

  Future<void> _onDealSaved(
    DealSaved event,
    Emitter<DealsState> emit,
  ) async {
    // Track current state for rollback if needed
    final currentState = state;

    // Update deals list to show as saved
    if (currentState is DealsLoaded || currentState is DealsLoading) {
      final updatedDeals = currentState.deals.map((deal) {
        if (deal['id'] == event.dealId) {
          return {
            ...deal,
            'isSaved': event.isSaving,
          };
        }
        return deal;
      }).toList();

      emit(DealsLoaded(updatedDeals));
    }

    try {
      // In a real app, you would call the API to save the deal
      // await dealsRepository.saveDeal(event.dealId, event.isSaving);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Success is already reflected in the state update above
    } catch (e) {
      // On error, revert to previous state
      emit(DealsError('Failed to save deal: $e'));

      if (currentState is DealsLoaded) {
        emit(DealsLoaded(currentState.deals));
      } else if (currentState is DealDetails) {
        emit(DealDetails(
          dealDetails: currentState.dealDetails,
          deals: currentState.deals,
        ));
      }
    }
  }

  // Helper methods to generate mock data
  List<Map<String, dynamic>> _getMockDeals({
    String? category,
    String? searchQuery,
  }) {
    // Generate some mock deals
    final deals = List.generate(
      15,
      (index) {
        final discountPercentage = (10 + (index % 5) * 10);
        final isFeatured = index % 5 == 0;
        final endDate = DateTime.now().add(Duration(days: 3 + index * 2));
        final dealCategory = _getCategoryForIndex(index);

        return {
          'id': 'deal-$index',
          'title':
              'Special $discountPercentage% Off on ${dealCategory.substring(0, dealCategory.length - 1)}',
          'description':
              'Enjoy a special discount on our premium services. Limited time offer!',
          'imageUrl': 'https://picsum.photos/500/300?random=$index',
          'provider': 'Provider ${index % 7 + 1}',
          'originalPrice': 100.0 + (index * 50),
          'discountedPrice':
              (100.0 + (index * 50)) * (1 - discountPercentage / 100),
          'discountPercentage': discountPercentage,
          'startDate':
              DateTime.now().subtract(Duration(days: index)).toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'category': dealCategory,
          'destination': 'Destination ${index % 5 + 1}',
          'destinationId': 'dest-${index % 5 + 1}',
          'isFeatured': isFeatured,
          'isExpired': false,
          'isRedeemed': false,
          'isSaved': false,
          'termsAndConditions':
              'Standard terms and conditions apply. Cannot be combined with other offers.',
          'redemptionInstructions': 'Show this offer at the counter to redeem.',
          'popularity': isFeatured ? 100 + index : 50 + index,
          'code': 'DEAL${index}OFF',
        };
      },
    );

    // Filter by category if provided
    final filteredByCategory = category == null || category == 'All Deals'
        ? deals
        : deals.where((deal) => deal['category'] == category).toList();

    // Filter by search query if provided
    final searchResults = searchQuery == null || searchQuery.isEmpty
        ? filteredByCategory
        : filteredByCategory.where((deal) {
            final title = deal['title'] as String;
            final description = deal['description'] as String;
            final provider = deal['provider'] as String;
            return title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                description.toLowerCase().contains(searchQuery.toLowerCase()) ||
                provider.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

    return searchResults;
  }

  String _getCategoryForIndex(int index) {
    final categories = [
      'Hotels',
      'Restaurants',
      'Activities',
      'Transport',
      'Packages',
    ];

    return categories[index % categories.length];
  }

  Map<String, dynamic> _getMockDealDetails(String dealId) {
    // Parse index from deal ID
    final index = int.tryParse(dealId.split('-').last) ?? 0;

    final discountPercentage = (10 + (index % 5) * 10);
    final isFeatured = index % 5 == 0;
    final endDate = DateTime.now().add(Duration(days: 3 + index * 2));
    final dealCategory = _getCategoryForIndex(index);

    // Enhanced deal details (more info than in the list)
    return {
      'id': dealId,
      'title':
          'Special $discountPercentage% Off on ${dealCategory.substring(0, dealCategory.length - 1)}',
      'description':
          'Enjoy a special discount on our premium services. Limited time offer!',
      'longDescription': 'This is an exclusive offer for our valued customers. '
          'Take advantage of this amazing deal and experience the best services we have to offer. '
          'We pride ourselves on providing exceptional quality and customer satisfaction.',
      'imageUrl': 'https://picsum.photos/500/300?random=$index',
      'galleryImages': List.generate(
        4,
        (i) => 'https://picsum.photos/500/300?random=${index * 10 + i}',
      ),
      'provider': 'Provider ${index % 7 + 1}',
      'providerLogo': 'https://picsum.photos/100/100?random=${index + 100}',
      'providerRating': 4.0 + (index % 10) / 10,
      'originalPrice': 100.0 + (index * 50),
      'discountedPrice':
          (100.0 + (index * 50)) * (1 - discountPercentage / 100),
      'discountPercentage': discountPercentage,
      'startDate':
          DateTime.now().subtract(Duration(days: index)).toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'category': dealCategory,
      'destination': 'Destination ${index % 5 + 1}',
      'destinationId': 'dest-${index % 5 + 1}',
      'location': 'Location Address, City, Country',
      'coordinates': {
        'latitude': 37.7749 + (index / 100),
        'longitude': -122.4194 + (index / 100),
      },
      'isFeatured': isFeatured,
      'isExpired': false,
      'isRedeemed': false,
      'isSaved': false,
      'termsAndConditions': [
        'Offer valid until ${endDate.day}/${endDate.month}/${endDate.year}.',
        'Cannot be combined with other promotions or discounts.',
        'Subject to availability.',
        'Reservation required in advance.',
        'No cash value or cash back.',
        'Management reserves the right to modify or cancel the promotion at any time.',
      ],
      'redemptionInstructions': [
        'Show this offer on your device at the time of purchase.',
        'Mention the promo code: DEAL${index}OFF',
        'Valid ID may be required for verification.',
      ],
      'popularity': isFeatured ? 100 + index : 50 + index,
      'code': 'DEAL${index}OFF',
      'reviews': List.generate(
        5,
        (i) => {
          'id': 'review-$i-$dealId',
          'userName': 'User ${i + 1}',
          'userPhoto':
              i % 2 == 0 ? null : 'https://i.pravatar.cc/150?img=${i + 10}',
          'rating': 3.0 + (i % 3),
          'comment':
              'This was a great deal! ${i % 2 == 0 ? "Highly recommended." : "Would use again."}',
          'date':
              DateTime.now().subtract(Duration(days: i * 3)).toIso8601String(),
        },
      ),
      'relatedDeals': List.generate(
        3,
        (i) => {
          'id': 'deal-${index + i + 1}',
          'title': 'Related Deal ${i + 1}',
          'imageUrl':
              'https://picsum.photos/500/300?random=${index * 3 + i + 100}',
          'discountPercentage': 15 + (i * 5),
          'category': _getCategoryForIndex(index + i + 1),
        },
      ),
    };
  }
}
