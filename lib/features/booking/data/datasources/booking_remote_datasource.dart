import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';
import '../models/time_slot_model.dart';

/// Fuente de datos remota para reservas
abstract class BookingRemoteDataSource {
  Future<List<TimeSlotModel>> getAvailableTimeSlots(DateTime date);
  Future<BookingModel> createBooking({
    required String userId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
  });
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<void> cancelBooking(String bookingId);
  Future<BookingModel> getBookingById(String bookingId);

  // Métodos de administrador
  Future<List<BookingModel>> getAllBookings();
  Future<BookingModel> confirmBooking(String bookingId);
  Future<BookingModel> rejectBooking({
    required String bookingId,
    required String reason,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TimeSlotModel>> getAvailableTimeSlots(DateTime date) async {
    try {
      // UNA SOLA CONSULTA para todas las reservas del día
      final baseDate = DateTime(date.year, date.month, date.day);
      final bookingsSnapshot = await firestore
          .collection('bookings')
          .where('date', isEqualTo: Timestamp.fromDate(baseDate))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      // Convertir todas las reservas a modelos
      final bookedSlots = bookingsSnapshot.docs
          .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Crear set de horas ocupadas para búsqueda rápida
      final occupiedHours = <int>{};
      for (var booking in bookedSlots) {
        for (int i = 0; i < booking.durationHours; i++) {
          occupiedHours.add(booking.startTime.hour + i);
        }
      }

      // Generar horarios de 6am a 10pm
      final timeSlots = <TimeSlotModel>[];
      for (int hour = 6; hour <= 22; hour++) {
        final startTime = baseDate.add(Duration(hours: hour));
        final endTime = startTime.add(const Duration(hours: 1));

        // Verificar disponibilidad directamente desde el set
        final isAvailable = !occupiedHours.contains(hour);

        // Precio diferenciado: día (6am-6pm) vs noche (6pm-11pm)
        final pricePerHour = hour < 18 ? 50.0 : 70.0;

        timeSlots.add(TimeSlotModel(
          id: '${date.toIso8601String()}_$hour',
          startTime: startTime,
          endTime: endTime,
          isAvailable: isAvailable,
          pricePerHour: pricePerHour,
        ));
      }

      return timeSlots;
    } catch (e) {
      throw Exception('Error al obtener horarios: $e');
    }
  }

  @override
  Future<BookingModel> createBooking({
    required String userId,
    required DateTime date,
    required DateTime startTime,
    required int durationHours,
  }) async {
    try {
      final totalPrice = durationHours * 50.0; // 50 soles por hora

      final booking = BookingModel(
        id: '', // Se generará por Firestore
        userId: userId,
        date: DateTime(date.year, date.month, date.day),
        startTime: startTime,
        durationHours: durationHours,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef = await firestore.collection('bookings').add(booking.toJson());

      return BookingModel(
        id: docRef.id,
        userId: booking.userId,
        date: booking.date,
        startTime: booking.startTime,
        durationHours: booking.durationHours,
        totalPrice: booking.totalPrice,
        status: booking.status,
        createdAt: booking.createdAt,
      );
    } catch (e) {
      throw Exception('Error al crear reserva: $e');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener reservas: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
      });
    } catch (e) {
      throw Exception('Error al cancelar reserva: $e');
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final doc = await firestore.collection('bookings').doc(bookingId).get();

      if (!doc.exists) {
        throw Exception('Reserva no encontrada');
      }

      return BookingModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Error al obtener reserva: $e');
    }
  }

  @override
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final snapshot = await firestore
          .collection('bookings')
          .orderBy('date', descending: true)
          .get();

      // Obtener datos de usuario para cada reserva
      final bookings = <BookingModel>[];
      for (var doc in snapshot.docs) {
        final bookingData = doc.data();
        final userId = bookingData['userId'] as String;

        // Obtener datos del usuario
        final userDoc = await firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();

        bookings.add(BookingModel.fromJson({
          ...bookingData,
          'id': doc.id,
          'userName': userData?['name'] ?? 'Usuario',
          'userPhone': userData?['phone'],
          'userEmail': userData?['email'],
        }));
      }

      return bookings;
    } catch (e) {
      throw Exception('Error al obtener todas las reservas: $e');
    }
  }

  @override
  Future<BookingModel> confirmBooking(String bookingId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.confirmed.name,
      });

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Error al confirmar reserva: $e');
    }
  }

  @override
  Future<BookingModel> rejectBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
        'rejectionReason': reason,
      });

      return await getBookingById(bookingId);
    } catch (e) {
      throw Exception('Error al rechazar reserva: $e');
    }
  }
}
