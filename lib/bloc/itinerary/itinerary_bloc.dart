import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/bloc/itinerary/itinerary_event.dart';
import 'package:taprobana_trails/bloc/itinerary/itinerary_state.dart';
import 'package:taprobana_trails/data/repositories/itinerary_repository.dart';

/// BLoC for managing itinerary data.
class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  final ItineraryRepository _itineraryRepository;
  
  /// Creates a new instance of [ItineraryBloc].
  ItineraryBloc({
    required ItineraryRepository itineraryRepository,
  })  : _itineraryRepository = itineraryRepository,
        super(ItineraryInitial()) {
    on<LoadItineraries>(_onLoadItineraries);
    on<LoadItineraryDetails>(_onLoadItineraryDetails);
    on<CreateItinerary>(_onCreateItinerary);
    on<UpdateItinerary>(_onUpdateItinerary);
    on<DeleteItinerary>(_onDeleteItinerary);
    on<AddItineraryItem>(_onAddItineraryItem);
    on<UpdateItineraryItem>(_onUpdateItineraryItem);
    on<DeleteItineraryItem>(_onDeleteItineraryItem);
    on<ReorderItineraryItems>(_onReorderItineraryItems);
    on<ShareItinerary>(_onShareItinerary);
    on<GenerateSuggestedItinerary>(_onGenerateSuggestedItinerary);
  }
  
  Future<void> _onLoadItineraries(
    LoadItineraries event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItinerariesLoading());
      
      final itineraries = await _itineraryRepository.getItineraries(
        userId: event.userId,
      );
      
      emit(ItinerariesLoaded(itineraries: itineraries));
    } catch (e) {
      debugPrint('Error loading itineraries: $e');
      emit(ItineraryError(message: 'Failed to load itineraries'));
    }
  }
  
  Future<void> _onLoadItineraryDetails(
    LoadItineraryDetails event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryDetailsLoading());
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: event.itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Itinerary not found'));
      }
    } catch (e) {
      debugPrint('Error loading itinerary details: $e');
      emit(ItineraryError(message: 'Failed to load itinerary details'));
    }
  }
  
  Future<void> _onCreateItinerary(
    CreateItinerary event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      final itineraryId = await _itineraryRepository.createItinerary(
        userId: event.userId,
        title: event.title,
        startDate: event.startDate,
        endDate: event.endDate,
        destination: event.destination,
      );
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryActionSuccess());
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Failed to create itinerary'));
      }
    } catch (e) {
      debugPrint('Error creating itinerary: $e');
      emit(ItineraryError(message: 'Failed to create itinerary'));
    }
  }
  
  Future<void> _onUpdateItinerary(
    UpdateItinerary event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      await _itineraryRepository.updateItinerary(
        itineraryId: event.itineraryId,
        title: event.title,
        startDate: event.startDate,
        endDate: event.endDate,
        destination: event.destination,
      );
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: event.itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryActionSuccess());
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Failed to update itinerary'));
      }
    } catch (e) {
      debugPrint('Error updating itinerary: $e');
      emit(ItineraryError(message: 'Failed to update itinerary'));
    }
  }
  
  Future<void> _onDeleteItinerary(
    DeleteItinerary event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      await _itineraryRepository.deleteItinerary(
        itineraryId: event.itineraryId,
      );
      
      emit(ItineraryActionSuccess());
      
      // Load updated itineraries list
      final itineraries = await _itineraryRepository.getItineraries(
        userId: event.userId,
      );
      
      emit(ItinerariesLoaded(itineraries: itineraries));
    } catch (e) {
      debugPrint('Error deleting itinerary: $e');
      emit(ItineraryError(message: 'Failed to delete itinerary'));
    }
  }
  
  Future<void> _onAddItineraryItem(
    AddItineraryItem event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      await _itineraryRepository.addItineraryItem(
        itineraryId: event.itineraryId,
        item: event.item,
      );
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: event.itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryActionSuccess());
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Failed to add itinerary item'));
      }
    } catch (e) {
      debugPrint('Error adding itinerary item: $e');
      emit(ItineraryError(message: 'Failed to add itinerary item'));
    }
  }
  
  Future<void> _onUpdateItineraryItem(
    UpdateItineraryItem event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      await _itineraryRepository.updateItineraryItem(
        itineraryId: event.itineraryId,
        itemId: event.itemId,
        item: event.item,
      );
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: event.itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryActionSuccess());
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Failed to update itinerary item'));
      }
    } catch (e) {
      debugPrint('Error updating itinerary item: $e');
      emit(ItineraryError(message: 'Failed to update itinerary item'));
    }
  }
  
  Future<void> _onDeleteItineraryItem(
    DeleteItineraryItem event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      await _itineraryRepository.deleteItineraryItem(
        itineraryId: event.itineraryId,
        itemId: event.itemId,
      );
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: event.itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryActionSuccess());
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Failed to delete itinerary item'));
      }
    } catch (e) {
      debugPrint('Error deleting itinerary item: $e');
      emit(ItineraryError(message: 'Failed to delete itinerary item'));
    }
  }
  
  Future<void> _onReorderItineraryItems(
    ReorderItineraryItems event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryActionLoading());
      
      await _itineraryRepository.reorderItineraryItems(
        itineraryId: event.itineraryId,
        itemIds: event.itemIds,
      );
      
      final itinerary = await _itineraryRepository.getItinerary(
        itineraryId: event.itineraryId,
      );
      
      if (itinerary != null) {
        emit(ItineraryActionSuccess());
        emit(ItineraryDetailsLoaded(itinerary: itinerary));
      } else {
        emit(ItineraryError(message: 'Failed to reorder itinerary items'));
      }
    } catch (e) {
      debugPrint('Error reordering itinerary items: $e');
      emit(ItineraryError(message: 'Failed to reorder itinerary items'));
    }
  }
  
  Future<void> _onShareItinerary(
    ShareItinerary event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(ItineraryShareLoading());
      
      final shareUrl = await _itineraryRepository.generateShareLink(
        itineraryId: event.itineraryId,
      );
      
      emit(ItineraryShareSuccess(shareUrl: shareUrl));
    } catch (e) {
      debugPrint('Error sharing itinerary: $e');
      emit(ItineraryError(message: 'Failed to share itinerary'));
    }
  }
  
  Future<void> _onGenerateSuggestedItinerary(
    GenerateSuggestedItinerary event,
    Emitter<ItineraryState> emit,
  ) async {
    try {
      emit(SuggestedItineraryLoading());
      
      final suggestedItinerary = await _itineraryRepository.generateSuggestedItinerary(
        userId: event.userId,
        destination: event.destination,
        startDate: event.startDate,
        endDate: event.endDate,
        preferences: event.preferences,
      );
      
      emit(SuggestedItineraryLoaded(itinerary: suggestedItinerary));
    } catch (e) {
      debugPrint('Error generating suggested itinerary: $e');
      emit(ItineraryError(message: 'Failed to generate suggested itinerary'));
    }
  }
}