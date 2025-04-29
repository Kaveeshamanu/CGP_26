import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/data/models/destination.dart';
import 'package:taprobana_trails/data/repositories/destination_repository.dart';

part 'destination_event.dart';
part 'destination_state.dart';

/// BLoC for managing destination data.
class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final DestinationRepository _destinationRepository;
  
  /// Creates a new instance of [DestinationBloc].
  DestinationBloc({
    required DestinationRepository destinationRepository,
  })  : _destinationRepository = destinationRepository,
        super(DestinationInitial()) {
    on<LoadDestinations>(_onLoadDestinations);
    on<LoadDestinationDetails>(_onLoadDestinationDetails);
    on<LoadTrendingDestinations>(_onLoadTrendingDestinations);
    on<FilterDestinations>(_onFilterDestinations);
    on<SaveDestination>(_onSaveDestination);
    on<UnsaveDestination>(_onUnsaveDestination);
    on<SearchDestinations>(_onSearchDestinations);
  }
  
  Future<void> _onLoadDestinations(
    LoadDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(DestinationsLoading());
      
      final destinations = await _destinationRepository.getDestinations(
        category: event.category,
      );
      
      emit(DestinationsLoaded(destinations: destinations));
    } catch (e) {
      debugPrint('Error loading destinations: $e');
      emit(DestinationsError(message: 'Failed to load destinations'));
    }
  }
  
  Future<void> _onLoadDestinationDetails(
    LoadDestinationDetails event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(DestinationDetailsLoading());
      
      final destination = await _destinationRepository.getDestination(
        event.destinationId,
      );
      
      if (destination != null) {
        emit(DestinationDetailsLoaded(destination: destination));
      } else {
        emit(DestinationsError(message: 'Destination not found'));
      }
    } catch (e) {
      debugPrint('Error loading destination details: $e');
      emit(DestinationsError(message: 'Failed to load destination details'));
    }
  }
  
  Future<void> _onLoadTrendingDestinations(
    LoadTrendingDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(TrendingDestinationsLoading());
      
      final destinations = await _destinationRepository.getTrendingDestinations();
      
      emit(TrendingDestinationsLoaded(destinations: destinations));
    } catch (e) {
      debugPrint('Error loading trending destinations: $e');
      emit(DestinationsError(message: 'Failed to load trending destinations'));
    }
  }
  
  Future<void> _onFilterDestinations(
    FilterDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(DestinationsLoading());
      
      final destinations = await _destinationRepository.filterDestinations(
        filters: event.filters,
      );
      
      emit(DestinationsLoaded(destinations: destinations));
    } catch (e) {
      debugPrint('Error filtering destinations: $e');
      emit(DestinationsError(message: 'Failed to filter destinations'));
    }
  }
  
  Future<void> _onSaveDestination(
    SaveDestination event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      await _destinationRepository.saveDestination(
        userId: event.userId,
        destinationId: event.destinationId,
      );
      
      // Re-emit the current state with updated saved status
      if (state is DestinationDetailsLoaded) {
        final currentState = state as DestinationDetailsLoaded;
        final updatedDestination = currentState.destination.copyWith(
          isSaved: true, isBookmarked: true, isFavorite: true,
        );
        
        emit(DestinationDetailsLoaded(destination: updatedDestination));
      }
    } catch (e) {
      debugPrint('Error saving destination: $e');
      emit(DestinationActionError(message: 'Failed to save destination'));
    }
  }
  
  Future<void> _onUnsaveDestination(
    UnsaveDestination event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      await _destinationRepository.unsaveDestination(
        userId: event.userId,
        destinationId: event.destinationId,
      );
      
      // Re-emit the current state with updated saved status
      if (state is DestinationDetailsLoaded) {
        final currentState = state as DestinationDetailsLoaded;
        final updatedDestination = currentState.destination.copyWith(
          isSaved: false, isFavorite: false, isBookmarked: false,
        );
        
        emit(DestinationDetailsLoaded(destination: updatedDestination));
      }
    } catch (e) {
      debugPrint('Error unsaving destination: $e');
      emit(DestinationActionError(message: 'Failed to unsave destination'));
    }
  }
  
  Future<void> _onSearchDestinations(
    SearchDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(DestinationsLoading());
      
      final destinations = await _destinationRepository.searchDestinations(
        query: event.query,
      );
      
      emit(DestinationsLoaded(destinations: destinations));
    } catch (e) {
      debugPrint('Error searching destinations: $e');
      emit(DestinationsError(message: 'Failed to search destinations'));
    }
  }
}