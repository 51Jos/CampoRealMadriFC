import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para confirmar una reserva (solo admin)
class ConfirmBookingUseCase {
  final BookingRepository repository;

  ConfirmBookingUseCase(this.repository);

  Future<Either<Failure, Booking>> call(String bookingId) async {
    return await repository.confirmBooking(bookingId);
  }
}
