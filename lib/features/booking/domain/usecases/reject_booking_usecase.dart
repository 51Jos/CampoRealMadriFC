import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para rechazar una reserva (solo admin)
class RejectBookingUseCase {
  final BookingRepository repository;

  RejectBookingUseCase(this.repository);

  Future<Either<Failure, Booking>> call({
    required String bookingId,
    required String reason,
  }) async {
    return await repository.rejectBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }
}
