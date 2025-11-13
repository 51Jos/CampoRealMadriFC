import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

/// Implementación del repositorio de reservas
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots(
      DateTime date) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final timeSlots = await remoteDataSource.getAvailableTimeSlots(date);
      return Right(timeSlots);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> createBooking({
    required String userId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final booking = await remoteDataSource.createBooking(
        userId: userId,
        date: date,
        startTime: startTime,
        durationHours: durationHours,
      );
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final bookings = await remoteDataSource.getUserBookings(userId);
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.cancelBooking(bookingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final booking = await remoteDataSource.getBookingById(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getAllBookings() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final bookings = await remoteDataSource.getAllBookings();
      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> confirmBooking(String bookingId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final booking = await remoteDataSource.confirmBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> rejectBooking({
    required String bookingId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final booking = await remoteDataSource.rejectBooking(
        bookingId: bookingId,
        reason: reason,
      );
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> createAdminBooking({
    required String adminUserId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
    required String clientName,
    required String clientPhone,
    String? clientEmail,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final booking = await remoteDataSource.createAdminBooking(
        adminUserId: adminUserId,
        date: date,
        startTime: startTime,
        durationHours: durationHours,
        clientName: clientName,
        clientPhone: clientPhone,
        clientEmail: clientEmail,
      );
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
