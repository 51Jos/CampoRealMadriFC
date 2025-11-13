import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../entities/time_slot.dart';

/// Contrato del repositorio de reservas
abstract class BookingRepository {
  /// Obtiene los horarios disponibles para una fecha específica
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots(DateTime date);

  /// Crea una nueva reserva
  Future<Either<Failure, Booking>> createBooking({
    required String userId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
  });

  /// Obtiene las reservas del usuario
  Future<Either<Failure, List<Booking>>> getUserBookings(String userId);

  /// Cancela una reserva
  Future<Either<Failure, void>> cancelBooking(String bookingId);

  /// Obtiene los detalles de una reserva
  Future<Either<Failure, Booking>> getBookingById(String bookingId);

  // Métodos de administrador

  /// Obtiene todas las reservas (solo admin)
  Future<Either<Failure, List<Booking>>> getAllBookings();

  /// Confirma una reserva (solo admin)
  Future<Either<Failure, Booking>> confirmBooking(String bookingId);

  /// Rechaza una reserva con motivo (solo admin)
  Future<Either<Failure, Booking>> rejectBooking({
    required String bookingId,
    required String reason,
  });

  /// Crea una reserva para un cliente (solo admin)
  Future<Either<Failure, Booking>> createAdminBooking({
    required String adminUserId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
    required String clientName,
    required String clientPhone,
    String? clientEmail,
  });
}
