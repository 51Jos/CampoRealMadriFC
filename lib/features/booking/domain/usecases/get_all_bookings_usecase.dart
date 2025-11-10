import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para obtener todas las reservas (solo admin)
class GetAllBookingsUseCase {
  final BookingRepository repository;

  GetAllBookingsUseCase(this.repository);

  Future<Either<Failure, List<Booking>>> call() async {
    return await repository.getAllBookings();
  }
}
