part of 'accommodation_bloc.dart';

/// Base class for all accommodation events.
abstract class AccommodationEvent extends Equatable {
  const AccommodationEvent();

  @override
  List<Object?> get props => [];
}

/// Event that is fired when accommodations need to be loaded.
class LoadAccommodations extends AccommodationEvent {
  final String? destinationId;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? guestCount;

  const LoadAccommodations({
    this.destinationId,
    this.checkInDate,
    this.checkOutDate,
    this.guestCount,
  });

  @override
  List<Object?> get props =>
      [destinationId, checkInDate, checkOutDate, guestCount];
}

/// Event that is fired when accommodation details need to be loaded.
class LoadAccommodationDetails extends AccommodationEvent {
  final String accommodationId;

  const LoadAccommodationDetails({required this.accommodationId});

  @override
  List<Object> get props => [accommodationId];
}

/// Event that is fired when accommodations need to be filtered.
class FilterAccommodations extends AccommodationEvent {
  final Map<String, dynamic> filters;

  const FilterAccommodations({required this.filters});

  @override
  List<Object> get props => [filters];
}

/// Event that is fired when an accommodation is saved.
class SaveAccommodation extends AccommodationEvent {
  final String userId;
  final String accommodationId;

  const SaveAccommodation(
      {required this.userId, required this.accommodationId});

  @override
  List<Object> get props => [userId, accommodationId];
}

/// Event that is fired when an accommodation is unsaved.
class UnsaveAccommodation extends AccommodationEvent {
  final String userId;
  final String accommodationId;

  const UnsaveAccommodation(
      {required this.userId, required this.accommodationId});

  @override
  List<Object> get props => [userId, accommodationId];
}

/// Event that is fired when accommodations need to be searched.
class SearchAccommodations extends AccommodationEvent {
  final String query;
  final String? destinationId;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? guestCount;
  final List<String>? amenities;
  final double? minPrice;
  final double? maxPrice;
  final String? accommodationType;
  final double? minRating;

  const SearchAccommodations({
    required this.query,
    this.destinationId,
    this.checkInDate,
    this.checkOutDate,
    this.guestCount,
    this.amenities,
    this.minPrice,
    this.maxPrice,
    this.accommodationType,
    this.minRating,
  });

  @override
  List<Object?> get props => [
        query,
        destinationId,
        checkInDate,
        checkOutDate,
        guestCount,
        amenities,
        minPrice,
        maxPrice,
        accommodationType,
        minRating,
      ];
}

/// Event that is fired when room types need to be loaded.
class LoadRoomTypes extends AccommodationEvent {
  final String accommodationId;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const LoadRoomTypes({
    required this.accommodationId,
    this.checkIn,
    this.checkOut,
  });

  @override
  List<Object?> get props => [accommodationId, checkIn, checkOut];
}

/// Event that is fired when room availability needs to be checked.
class CheckRoomAvailability extends AccommodationEvent {
  final String accommodationId;
  final String roomTypeId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  const CheckRoomAvailability({
    required this.accommodationId,
    required this.roomTypeId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });

  @override
  List<Object> get props => [
        accommodationId,
        roomTypeId,
        checkIn,
        checkOut,
        guests,
      ];
}

/// Event that is fired when accommodation availability needs to be checked.
class AccommodationCheckAvailability extends AccommodationEvent {
  final String? accommodationId;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const AccommodationCheckAvailability({
    this.accommodationId,
    required this.checkInDate,
    required this.checkOutDate,
  });

  @override
  List<Object?> get props => [accommodationId, checkInDate, checkOutDate];
}

/// Event that is fired when a booking is submitted.
class AccommodationBooking extends AccommodationEvent {
  final String? accommodationId;
  final String userId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final double totalPrice;
  final String? specialRequests;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  const AccommodationBooking({
    this.accommodationId,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    required this.totalPrice,
    this.specialRequests,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
  });

  @override
  List<Object?> get props => [
        accommodationId,
        userId,
        checkInDate,
        checkOutDate,
        guestCount,
        totalPrice,
        specialRequests,
        customerName,
        customerEmail,
        customerPhone,
      ];
}
