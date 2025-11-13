import 'package:equatable/equatable.dart';

/// Eventos para el AdminBloc
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todas las reservas
class LoadAllBookingsEvent extends AdminEvent {
  const LoadAllBookingsEvent();
}

/// Evento para confirmar una reserva
class ConfirmBookingEvent extends AdminEvent {
  final String bookingId;

  const ConfirmBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Evento para rechazar una reserva
class RejectBookingEvent extends AdminEvent {
  final String bookingId;
  final String reason;

  const RejectBookingEvent({
    required this.bookingId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}

/// Evento para filtrar reservas por estado
class FilterBookingsByStatusEvent extends AdminEvent {
  final String? status; // null = todas

  const FilterBookingsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Evento para crear una reserva de admin con datos del cliente
class CreateAdminBookingEvent extends AdminEvent {
  final String adminUserId;
  final DateTime date;
  final DateTime startTime;
  final int durationHours;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;

  const CreateAdminBookingEvent({
    required this.adminUserId,
    required this.date,
    required this.startTime,
    required this.durationHours,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
  });

  @override
  List<Object?> get props => [
        adminUserId,
        date,
        startTime,
        durationHours,
        clientName,
        clientPhone,
        clientEmail,
      ];
}
