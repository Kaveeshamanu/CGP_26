import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:taprobana_trails/core/api/uber_api.dart';
import 'package:taprobana_trails/core/api/pickme_api.dart';
import 'package:taprobana_trails/data/models/ride.dart';
import 'package:taprobana_trails/data/models/transport_schedule.dart';
import 'package:taprobana_trails/data/repositories/transport_repository.dart';

part 'transport_event.dart';
part 'transport_state.dart';

/// BLoC for managing transport data.
class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final TransportRepository _transportRepository;
  final UberApiService _uberApiService;
  final PickMeApiService _pickMeApiService;
  
  /// Creates a new instance of [TransportBloc].
  TransportBloc({
    required TransportRepository transportRepository,
    required UberApiService uberApiService,
    required PickMeApiService pickMeApiService,
  })  : _transportRepository = transportRepository,
        _uberApiService = uberApiService,
        _pickMeApiService = pickMeApiService,
        super(TransportInitial()) {
    on<LoadPublicTransportOptions>(_onLoadPublicTransportOptions);
    on<LoadTransportSchedule>(_onLoadTransportSchedule);
    on<LoadRideOptions>(_onLoadRideOptions);
    on<RequestRide>(_onRequestRide);
    on<CancelRide>(_onCancelRide);
    on<TrackRide>(_onTrackRide);
    on<LoadRentals>(_onLoadRentals);
    on<BookRental>(_onBookRental);
  }
  
  get scheduleDays => null;
  
  Future<void> _onLoadPublicTransportOptions(
    LoadPublicTransportOptions event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(PublicTransportLoading());
      
      final options = await _transportRepository.getPublicTransportOptions(
        from: event.from,
        to: event.to,
        date: event.date,
      );
      
      emit(PublicTransportLoaded(options: options));
    } catch (e) {
      debugPrint('Error loading public transport options: $e');
      emit(TransportError(message: 'Failed to load public transport options'));
    }
  }
  
  Future<void> _onLoadTransportSchedule(
    LoadTransportSchedule event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(TransportScheduleLoading());
      
      final schedule = await _transportRepository.getTransportSchedule(
        transportType: event.transportType,
        route: event.route,
        date: event.date!,
      );
      
      emit(TransportScheduleLoaded(schedule: scheduleDays));
    } catch (e) {
      debugPrint('Error loading transport schedule: $e');
      emit(TransportError(message: 'Failed to load transport schedule'));
    }
  }
  
  Future<void> _onLoadRideOptions(
    LoadRideOptions event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(RideOptionsLoading());
      
      // Get rides from both Uber and PickMe
      final uberRides = await _uberApiService.getAvailableRides(
        startLatitude: event.startLatitude,
        startLongitude: event.startLongitude,
        endLatitude: event.endLatitude,
        endLongitude: event.endLongitude,
      );
      
      final pickMeRides = await _pickMeApiService.getAvailableRides(
        startLatitude: event.startLatitude,
        startLongitude: event.startLongitude,
        endLatitude: event.endLatitude,
        endLongitude: event.endLongitude,
      );
      
      // Combine the rides
      final allRides = [...uberRides, ...pickMeRides];
      
      emit(RideOptionsLoaded(rides: allRides));
    } catch (e) {
      debugPrint('Error loading ride options: $e');
      emit(TransportError(message: 'Failed to load ride options'));
    }
  }
  
  Future<void> _onRequestRide(
    RequestRide event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(RideRequestLoading());
      
      Map<String, dynamic> result;
      
      // Request ride based on provider
      if (event.provider.toLowerCase() == 'uber') {
        result = await _uberApiService.requestRide(
          productId: event.rideId,
          startLatitude: event.startLatitude,
          startLongitude: event.startLongitude,
          endLatitude: event.endLatitude,
          endLongitude: event.endLongitude,
          startAddress: event.startAddress,
          endAddress: event.endAddress,
        );
      } else { // PickMe
        result = await _pickMeApiService.requestRide(
          categoryId: event.rideId,
          startLatitude: event.startLatitude,
          startLongitude: event.startLongitude,
          endLatitude: event.endLatitude,
          endLongitude: event.endLongitude,
          startAddress: event.startAddress,
          endAddress: event.endAddress,
        );
      }
      
      emit(RideRequestSuccess(
        requestId: result['request_id'] ?? result['booking_id'],
        estimatedPickupTime: DateTime.now().add(Duration(minutes: 5)), // Placeholder
        provider: event.provider,
      ));
    } catch (e) {
      debugPrint('Error requesting ride: $e');
      emit(TransportError(message: 'Failed to request ride'));
    }
  }
  
  Future<void> _onCancelRide(
    CancelRide event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(RideCancelLoading());
      
      bool success;
      
      // Cancel ride based on provider
      if (event.provider.toLowerCase() == 'uber') {
        success = await _uberApiService.cancelRide(event.requestId);
      } else { // PickMe
        success = await _pickMeApiService.cancelRide(event.requestId);
      }
      
      if (success) {
        emit(RideCancelSuccess());
      } else {
        emit(TransportError(message: 'Failed to cancel ride'));
      }
    } catch (e) {
      debugPrint('Error cancelling ride: $e');
      emit(TransportError(message: 'Failed to cancel ride'));
    }
  }
  
  Future<void> _onTrackRide(
    TrackRide event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(RideTrackingLoading());
      
      Map<String, dynamic> status;
      
      // Get ride status based on provider
      if (event.provider.toLowerCase() == 'uber') {
        status = await _uberApiService.checkRideStatus(event.requestId);
      } else { // PickMe
        status = await _pickMeApiService.checkRideStatus(event.requestId);
        
        // Also get driver location for PickMe
        final driverLocation = await _pickMeApiService.getDriverLocation(event.requestId);
        status['driver_location'] = driverLocation;
      }
      
      emit(RideTrackingUpdate(
        status: status['status'],
        driverName: status['driver']?['name'] ?? 'Driver',
        driverPhone: status['driver']?['phone_number'] ?? '',
        vehicleDetails: '${status['vehicle']?['make'] ?? ''} ${status['vehicle']?['model'] ?? ''} - ${status['vehicle']?['license_plate'] ?? ''}',
        estimatedArrival: DateTime.now().add(Duration(minutes: status['eta'] ?? 5)),
        driverLatitude: status['driver_location']?['latitude'] ?? 0.0,
        driverLongitude: status['driver_location']?['longitude'] ?? 0.0,
      ));
    } catch (e) {
      debugPrint('Error tracking ride: $e');
      emit(TransportError(message: 'Failed to track ride'));
    }
  }
  
  Future<void> _onLoadRentals(
    LoadRentals event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(RentalsLoading());
      
      final rentals = await _transportRepository.getRentals(
        location: event.location,
        startDate: event.startDate,
        endDate: event.endDate,
        vehicleType: event.vehicleType,
      );
      
      emit(RentalsLoaded(rentals: rentals));
    } catch (e) {
      debugPrint('Error loading rentals: $e');
      emit(TransportError(message: 'Failed to load rentals'));
    }
  }
  
  Future<void> _onBookRental(
    BookRental event,
    Emitter<TransportState> emit,
  ) async {
    try {
      emit(RentalBookingLoading());
      
      final bookingId = await _transportRepository.bookRental(
        rentalId: event.rentalId,
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(RentalBookingSuccess(bookingId: bookingId));
    } catch (e) {
      debugPrint('Error booking rental: $e');
      emit(TransportError(message: 'Failed to book rental'));
    }
  }
}