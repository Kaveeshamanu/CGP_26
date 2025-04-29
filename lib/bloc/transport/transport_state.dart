part of 'transport_bloc.dart';

/// Base class for all transport states.
abstract class TransportState extends Equatable {
  const TransportState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state of the transport bloc.
class TransportInitial extends TransportState {}

/// State when public transport options are being loaded.
class PublicTransportLoading extends TransportState {}

/// State when public transport options have been successfully loaded.
class PublicTransportLoaded extends TransportState {
  final List<Map<String, dynamic>> options;
  
  const PublicTransportLoaded({required this.options});
  
  @override
  List<Object> get props => [options];
}

/// State when transport schedule is being loaded.
class TransportScheduleLoading extends TransportState {}

/// State when transport schedule has been successfully loaded.
class TransportScheduleLoaded extends TransportState {
  final TransportSchedule schedule;
  
  const TransportScheduleLoaded({required this.schedule});
  
  @override
  List<Object> get props => [schedule];
}

/// State when ride options are being loaded.
class RideOptionsLoading extends TransportState {}

/// State when ride options have been successfully loaded.
class RideOptionsLoaded extends TransportState {
  final List<Ride> rides;
  
  const RideOptionsLoaded({required this.rides});
  
  @override
  List<Object> get props => [rides];
}

/// State when a ride request is being processed.
class RideRequestLoading extends TransportState {}

/// State when a ride request has been successfully processed.
class RideRequestSuccess extends TransportState {
  final String requestId;
  final DateTime estimatedPickupTime;
  final String provider; // 'uber' or 'pickme'
  
  const RideRequestSuccess({
    required this.requestId,
    required this.estimatedPickupTime,
    required this.provider,
  });
  
  @override
  List<Object> get props => [requestId, estimatedPickupTime, provider];
}

/// State when a ride cancellation is being processed.
class RideCancelLoading extends TransportState {}

/// State when a ride cancellation has been successfully processed.
class RideCancelSuccess extends TransportState {}

/// State when ride tracking is being loaded.
class RideTrackingLoading extends TransportState {}

/// State when ride tracking information has been updated.
class RideTrackingUpdate extends TransportState {
  final String status;
  final String driverName;
  final String driverPhone;
  final String vehicleDetails;
  final DateTime estimatedArrival;
  final double driverLatitude;
  final double driverLongitude;
  
  const RideTrackingUpdate({
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleDetails,
    required this.estimatedArrival,
    required this.driverLatitude,
    required this.driverLongitude,
  });
  
  @override
  List<Object> get props => [
    status,
    driverName,
    driverPhone,
    vehicleDetails,
    estimatedArrival,
    driverLatitude,
    driverLongitude,
  ];
}

/// State when rentals are being loaded.
class RentalsLoading extends TransportState {}

/// State when rentals have been successfully loaded.
class RentalsLoaded extends TransportState {
  final List<Map<String, dynamic>> rentals;
  
  const RentalsLoaded({required this.rentals});
  
  @override
  List<Object> get props => [rentals];
}

/// State when a rental booking is being processed.
class RentalBookingLoading extends TransportState {}

/// State when a rental booking has been successfully processed.
class RentalBookingSuccess extends TransportState {
  final String bookingId;
  
  const RentalBookingSuccess({required this.bookingId});
  
  @override
  List<Object> get props => [bookingId];
}

/// State when there is an error in transport operations.
class TransportError extends TransportState {
  final String message;
  
  const TransportError({required this.message});
  
  @override
  List<Object> get props => [message];
}