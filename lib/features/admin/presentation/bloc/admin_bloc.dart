import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/domain/usecases/add_payment_usecase.dart';
import '../../../booking/domain/usecases/confirm_booking_usecase.dart';
import '../../../booking/domain/usecases/create_admin_booking.dart';
import '../../../booking/domain/usecases/get_all_bookings_usecase.dart';
import '../../../booking/domain/usecases/reject_booking_usecase.dart';
import 'admin_event.dart';
import 'admin_state.dart';

/// BLoC para gestión de administrador
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAllBookingsUseCase getAllBookingsUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final RejectBookingUseCase rejectBookingUseCase;
  final CreateAdminBooking createAdminBooking;
  final AddPaymentUseCase addPaymentUseCase;

  AdminBloc({
    required this.getAllBookingsUseCase,
    required this.confirmBookingUseCase,
    required this.rejectBookingUseCase,
    required this.createAdminBooking,
    required this.addPaymentUseCase,
  }) : super(const AdminInitial()) {
    on<LoadAllBookingsEvent>(_onLoadAllBookings);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<RejectBookingEvent>(_onRejectBooking);
    on<FilterBookingsByStatusEvent>(_onFilterByStatus);
    on<CreateAdminBookingEvent>(_onCreateAdminBooking);
    on<AddPaymentEvent>(_onAddPayment);
  }

  Future<void> _onLoadAllBookings(
    LoadAllBookingsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    final result = await getAllBookingsUseCase();

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (bookings) {
        // Filtrar reservas del día actual en adelante y ordenar
        final filteredAndSorted = _filterAndSortBookings(bookings);

        emit(AdminBookingsLoaded(
          bookings: filteredAndSorted,
          filteredBookings: filteredAndSorted,
          currentFilter: null,
        ));
      },
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

  /// Filtra reservas del día actual en adelante y las ordena por fecha/hora
  List<Booking> _filterAndSortBookings(List<Booking> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filtrar solo reservas de hoy en adelante
    final futureBookings = bookings.where((booking) {
      final bookingDate = DateTime(
        booking.date.year,
        booking.date.month,
        booking.date.day,
      );
      return bookingDate.isAfter(today) || bookingDate.isAtSameMomentAs(today);
    }).toList();

    // Ordenar por fecha y hora (más próximas primero)
    futureBookings.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return a.startTime.compareTo(b.startTime);
    });

    return futureBookings;
  }

  List<Booking> _filterBookings(List<Booking> bookings, String? filter) {
    if (filter == null || filter == 'all') {
      return bookings;
    }

    return bookings.where((booking) {
      return booking.status.name == filter;
    }).toList();
  }

  Future<void> _onCreateAdminBooking(
    CreateAdminBookingEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    final result = await createAdminBooking(
      adminUserId: event.adminUserId,
      date: event.date,
      startTime: event.startTime,
      durationHours: event.durationHours,
      clientName: event.clientName,
      clientPhone: event.clientPhone,
      clientEmail: event.clientEmail,
    );

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (booking) => emit(AdminBookingCreated(booking)),
    );
  }

  Future<void> _onAddPayment(
    AddPaymentEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminBookingsLoaded) return;

    final currentState = state as AdminBookingsLoaded;
    emit(AdminProcessing(
      bookings: currentState.bookings,
      filteredBookings: currentState.filteredBookings,
      currentFilter: currentState.currentFilter,
    ));

    final result = await addPaymentUseCase(
      bookingId: event.bookingId,
      payment: event.payment,
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
          message: 'Pago registrado exitosamente',
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
}
