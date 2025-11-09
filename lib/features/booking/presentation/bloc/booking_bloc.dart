import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_available_time_slots.dart';
import '../../domain/usecases/get_user_bookings.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetAvailableTimeSlots getAvailableTimeSlots;
  final CreateBooking createBooking;
  final GetUserBookings getUserBookings;
  final CancelBooking cancelBooking;

  BookingBloc({
    required this.getAvailableTimeSlots,
    required this.createBooking,
    required this.getUserBookings,
    required this.cancelBooking,
  }) : super(const BookingInitial()) {
    on<LoadAvailableTimeSlotsEvent>(_onLoadAvailableTimeSlots);
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadUserBookingsEvent>(_onLoadUserBookings);
    on<CancelBookingEvent>(_onCancelBooking);
    on<SelectTimeSlotEvent>(_onSelectTimeSlot);
    on<ResetBookingEvent>(_onResetBooking);
  }

  Future<void> _onLoadAvailableTimeSlots(
    LoadAvailableTimeSlotsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await getAvailableTimeSlots(event.date);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (timeSlots) => emit(TimeSlotsLoaded(
        timeSlots: timeSlots,
        selectedDate: event.date,
      )),
    );
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await createBooking(
      userId: event.userId,
      date: event.date,
      startTime: event.startTime,
      durationHours: event.durationHours,
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  void _onSelectTimeSlot(
    SelectTimeSlotEvent event,
    Emitter<BookingState> emit,
  ) {
    if (state is TimeSlotsLoaded) {
      final currentState = state as TimeSlotsLoaded;
      final selectedIds = List<String>.from(currentState.selectedTimeSlotIds);

      // Toggle: si ya está seleccionado, lo quita; si no, lo agrega
      if (selectedIds.contains(event.timeSlotId)) {
        selectedIds.remove(event.timeSlotId);
      } else {
        selectedIds.add(event.timeSlotId);
      }

      // Ordenar los IDs por hora (para mantener el orden)
      selectedIds.sort();

      emit(currentState.copyWith(selectedTimeSlotIds: selectedIds));
    }
  }

  void _onResetBooking(
    ResetBookingEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(const BookingInitial());
  }

  Future<void> _onLoadUserBookings(
    LoadUserBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await getUserBookings(event.userId);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(UserBookingsLoaded(bookings)),
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    final result = await cancelBooking(event.bookingId);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (_) {
        // Mantener el estado actual después de cancelar
        // La UI debería recargar las reservas
      },
    );
  }
}
