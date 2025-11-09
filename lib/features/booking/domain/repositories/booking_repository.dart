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
}
