import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../entities/payment.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para agregar un pago a una reserva
class AddPaymentUseCase {
  final BookingRepository repository;

  AddPaymentUseCase(this.repository);

  Future<Either<Failure, Booking>> call({
    required String bookingId,
    required Payment payment,
  }) async {
    return await repository.addPayment(
      bookingId: bookingId,
      payment: payment,
    );
  }
}
