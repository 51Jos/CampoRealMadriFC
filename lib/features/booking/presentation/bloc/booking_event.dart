import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar horarios disponibles
class LoadAvailableTimeSlotsEvent extends BookingEvent {
  final DateTime date;

  const LoadAvailableTimeSlotsEvent(this.date);

  @override
  List<Object?> get props => [date];
}

/// Evento para crear una reserva
class CreateBookingEvent extends BookingEvent {
  final String userId;
  final DateTime date;
  final DateTime startTime;
  final int durationHours;

  const CreateBookingEvent({
    required this.userId,
    required this.date,
    required this.startTime,
    required this.durationHours,
  });

  @override
  List<Object?> get props => [userId, date, startTime, durationHours];
}

/// Evento para cargar reservas del usuario
class LoadUserBookingsEvent extends BookingEvent {
  final String userId;

  const LoadUserBookingsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Evento para seleccionar un horario
class SelectTimeSlotEvent extends BookingEvent {
  final String timeSlotId;

  const SelectTimeSlotEvent(this.timeSlotId);

  @override
  List<Object?> get props => [timeSlotId];
}

/// Evento para seleccionar duración
class SelectDurationEvent extends BookingEvent {
  final int hours;

  const SelectDurationEvent(this.hours);

  @override
  List<Object?> get props => [hours];
}

/// Evento para cancelar una reserva
class CancelBookingEvent extends BookingEvent {
  final String bookingId;

  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Evento para resetear el estado
class ResetBookingEvent extends BookingEvent {
  const ResetBookingEvent();
}
