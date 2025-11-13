import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para que el admin cree una reserva con datos del cliente
class CreateAdminBooking {
  final BookingRepository repository;

  CreateAdminBooking(this.repository);

  Future<Either<Failure, Booking>> call({
    required String adminUserId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
    required String clientName,
    required String clientPhone,
    String? clientEmail,
  }) async {
    return await repository.createAdminBooking(
      adminUserId: adminUserId,
      date: date,
      startTime: startTime,
      durationHours: durationHours,
      clientName: clientName,
      clientPhone: clientPhone,
      clientEmail: clientEmail,
    );
  }
}
