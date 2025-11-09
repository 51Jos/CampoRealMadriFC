import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/time_slot.dart';
import '../repositories/booking_repository.dart';

/// Caso de uso para obtener horarios disponibles
class GetAvailableTimeSlots {
  final BookingRepository repository;

  GetAvailableTimeSlots(this.repository);

  Future<Either<Failure, List<TimeSlot>>> call(DateTime date) async {
    return await repository.getAvailableTimeSlots(date);
  }
}
