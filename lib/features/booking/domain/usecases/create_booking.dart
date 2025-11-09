import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para crear una reserva
class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<Either<Failure, Booking>> call({
    required String userId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
  }) async {
    return await repository.createBooking(
      userId: userId,
      date: date,
      startTime: startTime,
      durationHours: durationHours,
    );
  }
}
