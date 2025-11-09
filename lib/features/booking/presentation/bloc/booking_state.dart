import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/time_slot.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

/// Estado para mostrar horarios disponibles
class TimeSlotsLoaded extends BookingState {
  final List<TimeSlot> timeSlots;
  final DateTime selectedDate;
  final List<String> selectedTimeSlotIds;

  const TimeSlotsLoaded({
    required this.timeSlots,
    required this.selectedDate,
    this.selectedTimeSlotIds = const [],
  });

  TimeSlotsLoaded copyWith({
    List<TimeSlot>? timeSlots,
    DateTime? selectedDate,
    List<String>? selectedTimeSlotIds,
  }) {
    return TimeSlotsLoaded(
      timeSlots: timeSlots ?? this.timeSlots,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlotIds: selectedTimeSlotIds ?? this.selectedTimeSlotIds,
    );
  }

  @override
  List<Object?> get props => [
        timeSlots,
        selectedDate,
        selectedTimeSlotIds,
      ];
}

/// Estado después de crear una reserva exitosamente
class BookingCreated extends BookingState {
  final Booking booking;

  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Estado para mostrar reservas del usuario
class UserBookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const UserBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
