// reservation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taprobana_trails/presentation/dining/reservation_screen.dart';

// Events
abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object> get props => [];
}

class SubmitReservation extends ReservationEvent {
  final ReservationRequest request;

  const SubmitReservation({required this.request});

  @override
  List<Object> get props => [request];
}

// States
abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationSuccess extends ReservationState {
  final String reservationId;

  const ReservationSuccess(this.reservationId);

  @override
  List<Object> get props => [reservationId];
}

class ReservationFailure extends ReservationState {
  final String message;

  const ReservationFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  ReservationBloc() : super(ReservationInitial()) {
    on<SubmitReservation>(_onSubmitReservation);
  }

  Future<void> _onSubmitReservation(
    SubmitReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    try {
      // Here you would typically call a repository or service
      // For this example we'll just simulate a successful reservation
      await Future.delayed(const Duration(seconds: 2));

      final reservationId = 'RES-${DateTime.now().millisecondsSinceEpoch}';
      emit(ReservationSuccess(reservationId));
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
  }
}
