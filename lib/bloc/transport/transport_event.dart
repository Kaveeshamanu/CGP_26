part of 'transport_bloc.dart';

/// Base class for all transport events.
abstract class TransportEvent extends Equatable {
  const TransportEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event that is fired when public transport options need to be loaded.
class LoadPublicTransportOptions extends TransportEvent {
  final String from;
  final String to;
  final DateTime? date;
  
  const LoadPublicTransportOptions({
    required this.from,
    required this.to,
    this.date,
  });
  
  @override
  List<Object?> get props => [from, to, date];
}

/// Event that is fired when transport schedule needs to be loaded.
class LoadTransportSchedule extends TransportEvent {
  final String transportType; // 'bus', 'train', etc.
  final String route;
  final DateTime? date;
  
  const LoadTransportSchedule({
    required this.transportType,
    required this.route,
    this.date,
  });
  
  @override
  List<Object?> get props => [transportType, route, date];
}

/// Event that is fired when ride options need to be loaded.
class LoadRideOptions extends TransportEvent {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  
  const LoadRideOptions({
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
  });
  
  @override
  List<Object> get props => [
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  ];
}

/// Event that is fired when a ride is requested.
class RequestRide extends TransportEvent {
  final String rideId;
  final String provider; // 'uber' or 'pickme'
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String? startAddress;
  final String? endAddress;
  
  const RequestRide({
    required this.rideId,
    required this.provider,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    this.startAddress,
    this.endAddress,
  });
  
  @override
  List<Object?> get props => [
    rideId,
    provider,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
    startAddress,
    endAddress,
  ];
}

/// Event that is fired when a ride is cancelled.
class CancelRide extends TransportEvent {
  final String requestId;
  final String provider; // 'uber' or 'pickme'
  
  const CancelRide({
    required this.requestId,
    required this.provider,
  });
  
  @override
  List<Object> get props => [requestId, provider];
}

/// Event that is fired when a ride needs to be tracked.
class TrackRide extends TransportEvent {
  final String requestId;
  final String provider; // 'uber' or 'pickme'
  
  const TrackRide({
    required this.requestId,
    required this.provider,
  });
  
  @override
  List<Object> get props => [requestId, provider];
}

/// Event that is fired when rentals need to be loaded.
class LoadRentals extends TransportEvent {
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String? vehicleType; // 'car', 'scooter', etc.
  
  const LoadRentals({
    required this.location,
    required this.startDate,
    required this.endDate,
    this.vehicleType,
  });
  
  @override
  List<Object?> get props => [location, startDate, endDate, vehicleType];
}

/// Event that is fired when a rental is booked.
class BookRental extends TransportEvent {
  final String rentalId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  
  const BookRental({
    required this.rentalId,
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object> get props => [rentalId, userId, startDate, endDate];
}