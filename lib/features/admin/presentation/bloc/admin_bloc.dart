import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/domain/usecases/confirm_booking_usecase.dart';
import '../../../booking/domain/usecases/get_all_bookings_usecase.dart';
import '../../../booking/domain/usecases/reject_booking_usecase.dart';
import 'admin_event.dart';
import 'admin_state.dart';

/// BLoC para gestión de administrador
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAllBookingsUseCase getAllBookingsUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final RejectBookingUseCase rejectBookingUseCase;

  AdminBloc({
    required this.getAllBookingsUseCase,
    required this.confirmBookingUseCase,
    required this.rejectBookingUseCase,
  }) : super(const AdminInitial()) {
    on<LoadAllBookingsEvent>(_onLoadAllBookings);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<RejectBookingEvent>(_onRejectBooking);
    on<FilterBookingsByStatusEvent>(_onFilterByStatus);
  }

  Future<void> _onLoadAllBookings(
    LoadAllBookingsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    final result = await getAllBookingsUseCase();

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (bookings) => emit(AdminBookingsLoaded(
        bookings: bookings,
        filteredBookings: bookings,
        currentFilter: null,
      )),
    );
  }

  Future<void> _onConfirmBooking(
    ConfirmBookingEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminBookingsLoaded) return;

    final currentState = state as AdminBookingsLoaded;
    emit(AdminProcessing(
      bookings: currentState.bookings,
      filteredBookings: currentState.filteredBookings,
      currentFilter: currentState.currentFilter,
    ));

    final result = await confirmBookingUseCase(event.bookingId);

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (updatedBooking) {
        // Actualizar la lista de reservas
        final updatedBookings = currentState.bookings.map((booking) {
          return booking.id == updatedBooking.id ? updatedBooking : booking;
        }).toList();

        final filteredBookings = _filterBookings(
          updatedBookings,
          currentState.currentFilter,
        );

        emit(AdminActionSuccess(
          message: 'Reserva confirmada exitosamente',
          bookings: updatedBookings,
          filteredBookings: filteredBookings,
          currentFilter: currentState.currentFilter,
        ));

        // Volver al estado cargado después de mostrar el mensaje
        Future.delayed(const Duration(seconds: 2), () {
          if (!emit.isDone) {
            emit(AdminBookingsLoaded(
              bookings: updatedBookings,
              filteredBookings: filteredBookings,
              currentFilter: currentState.currentFilter,
            ));
          }
        });
      },
    );
  }

  Future<void> _onRejectBooking(
    RejectBookingEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminBookingsLoaded) return;

    final currentState = state as AdminBookingsLoaded;
    emit(AdminProcessing(
      bookings: currentState.bookings,
      filteredBookings: currentState.filteredBookings,
      currentFilter: currentState.currentFilter,
    ));

    final result = await rejectBookingUseCase(
      bookingId: event.bookingId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (updatedBooking) {
        // Actualizar la lista de reservas
        final updatedBookings = currentState.bookings.map((booking) {
          return booking.id == updatedBooking.id ? updatedBooking : booking;
        }).toList();

        final filteredBookings = _filterBookings(
          updatedBookings,
          currentState.currentFilter,
        );

        emit(AdminActionSuccess(
          message: 'Reserva rechazada',
          bookings: updatedBookings,
          filteredBookings: filteredBookings,
          currentFilter: currentState.currentFilter,
        ));

        // Volver al estado cargado después de mostrar el mensaje
        Future.delayed(const Duration(seconds: 2), () {
          if (!emit.isDone) {
            emit(AdminBookingsLoaded(
              bookings: updatedBookings,
              filteredBookings: filteredBookings,
              currentFilter: currentState.currentFilter,
            ));
          }
        });
      },
    );
  }

  void _onFilterByStatus(
    FilterBookingsByStatusEvent event,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminBookingsLoaded) return;

    final currentState = state as AdminBookingsLoaded;
    final filteredBookings = _filterBookings(
      currentState.bookings,
      event.status,
    );

    emit(AdminBookingsLoaded(
      bookings: currentState.bookings,
      filteredBookings: filteredBookings,
      currentFilter: event.status,
    ));
  }

  List<Booking> _filterBookings(List<Booking> bookings, String? filter) {
    if (filter == null || filter == 'all') {
      return bookings;
    }

    return bookings.where((booking) {
      return booking.status.name == filter;
    }).toList();
  }
}
