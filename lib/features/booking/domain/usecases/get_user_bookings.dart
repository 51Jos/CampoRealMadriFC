import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para obtener las reservas de un usuario
class GetUserBookings {
  final BookingRepository repository;

  GetUserBookings(this.repository);

  Future<Either<Failure, List<Booking>>> call(String userId) async {
    return await repository.getUserBookings(userId);
  }
}
