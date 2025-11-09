import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para cancelar una reserva
class CancelBooking {
  final BookingRepository repository;

  CancelBooking(this.repository);

  Future<Either<Failure, void>> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}
