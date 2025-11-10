import 'package:equatable/equatable.dart';
import '../../../booking/domain/entities/booking.dart';

/// Estados para el AdminBloc
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Cargando reservas
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Reservas cargadas
class AdminBookingsLoaded extends AdminState {
  final List<Booking> bookings;
  final List<Booking> filteredBookings;
  final String? currentFilter;

  const AdminBookingsLoaded({
    required this.bookings,
    required this.filteredBookings,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [bookings, filteredBookings, currentFilter];

  AdminBookingsLoaded copyWith({
    List<Booking>? bookings,
    List<Booking>? filteredBookings,
    String? currentFilter,
  }) {
    return AdminBookingsLoaded(
      bookings: bookings ?? this.bookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

/// Procesando acción (confirmar/rechazar)
class AdminProcessing extends AdminState {
  final List<Booking> bookings;
  final List<Booking> filteredBookings;
  final String? currentFilter;

  const AdminProcessing({
    required this.bookings,
    required this.filteredBookings,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [bookings, filteredBookings, currentFilter];
}

/// Acción completada con éxito
class AdminActionSuccess extends AdminState {
  final String message;
  final List<Booking> bookings;
  final List<Booking> filteredBookings;
  final String? currentFilter;

  const AdminActionSuccess({
    required this.message,
    required this.bookings,
    required this.filteredBookings,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [message, bookings, filteredBookings, currentFilter];
}

/// Error
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
