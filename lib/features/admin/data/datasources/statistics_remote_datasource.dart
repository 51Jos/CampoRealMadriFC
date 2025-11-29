import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/domain/entities/payment.dart';
import '../../domain/entities/statistics.dart';

abstract class StatisticsRemoteDataSource {
  Future<Statistics> getStatistics();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final FirebaseFirestore firestore;

  StatisticsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Statistics> getStatistics() async {
    // Obtener todas las reservas confirmadas
    final bookingsSnapshot = await firestore
        .collection('bookings')
        .where('status', isEqualTo: 'confirmed')
        .get();

    final bookings = bookingsSnapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return BookingModel.fromJson(data);
        })
        .toList();

    // Calcular estadísticas
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    // Estadísticas de reservas
    final bookingStats = _calculateBookingStats(
      bookings,
      todayStart,
      weekStart,
      monthStart,
    );

    // Estadísticas de ingresos
    final incomeStats = _calculateIncomeStats(
      bookings,
      todayStart,
      weekStart,
      monthStart,
    );

    // Estadísticas de horas pico
    final peakHoursStats = _calculatePeakHoursStats(bookings);

    return Statistics(
      bookingStats: bookingStats,
      incomeStats: incomeStats,
      peakHoursStats: peakHoursStats,
    );
  }

  BookingStats _calculateBookingStats(
    List<BookingModel> bookings,
    DateTime todayStart,
    DateTime weekStart,
    DateTime monthStart,
  ) {
    int todayBookings = 0;
    int weekBookings = 0;
    int monthBookings = 0;
    double todayHours = 0;
    double weekHours = 0;
    double monthHours = 0;

    // Para el gráfico de la semana
    Map<DateTime, DailyBookingData> dailyMap = {};

    for (var booking in bookings) {
      final bookingDate = booking.date;
      final duration = booking.durationHours.toDouble();

      // Normalizar la fecha al inicio del día
      final normalizedDate = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
      );

      // Hoy
      if (bookingDate.isAfter(todayStart) ||
          bookingDate.isAtSameMomentAs(todayStart)) {
        todayBookings++;
        todayHours += duration;
      }

      // Esta semana
      if (bookingDate.isAfter(weekStart) ||
          bookingDate.isAtSameMomentAs(weekStart)) {
        weekBookings++;
        weekHours += duration;

        // Agregar al mapa diario
        if (!dailyMap.containsKey(normalizedDate)) {
          dailyMap[normalizedDate] = DailyBookingData(count: 0, hours: 0);
        }
        dailyMap[normalizedDate]!.count++;
        dailyMap[normalizedDate]!.hours += duration;
      }

      // Este mes
      if (bookingDate.isAfter(monthStart) ||
          bookingDate.isAtSameMomentAs(monthStart)) {
        monthBookings++;
        monthHours += duration;
      }
    }

    // Convertir el mapa a lista de DailyBooking
    final dailyBookings = dailyMap.entries
        .map((entry) => DailyBooking(
              date: entry.key,
              count: entry.value.count,
              hours: entry.value.hours,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return BookingStats(
      todayBookings: todayBookings,
      weekBookings: weekBookings,
      monthBookings: monthBookings,
      todayHours: todayHours,
      weekHours: weekHours,
      monthHours: monthHours,
      dailyBookings: dailyBookings,
    );
  }

  IncomeStats _calculateIncomeStats(
    List<BookingModel> bookings,
    DateTime todayStart,
    DateTime weekStart,
    DateTime monthStart,
  ) {
    double totalIncome = 0;
    double todayIncome = 0;
    double weekIncome = 0;
    double monthIncome = 0;

    double efectivoTotal = 0;
    double yapeTotal = 0;
    double plinTotal = 0;
    double transferenciaTotal = 0;

    for (var booking in bookings) {
      final bookingDate = booking.date;
      final payments = booking.payments;

      for (var payment in payments) {
        final amount = payment.amount;
        totalIncome += amount;

        // Por fecha
        if (bookingDate.isAfter(todayStart) ||
            bookingDate.isAtSameMomentAs(todayStart)) {
          todayIncome += amount;
        }
        if (bookingDate.isAfter(weekStart) ||
            bookingDate.isAtSameMomentAs(weekStart)) {
          weekIncome += amount;
        }
        if (bookingDate.isAfter(monthStart) ||
            bookingDate.isAtSameMomentAs(monthStart)) {
          monthIncome += amount;
        }

        // Por método de pago
        switch (payment.method) {
          case PaymentMethod.efectivo:
            efectivoTotal += amount;
            break;
          case PaymentMethod.yape:
            yapeTotal += amount;
            break;
          case PaymentMethod.plin:
            plinTotal += amount;
            break;
          case PaymentMethod.transferencia:
            transferenciaTotal += amount;
            break;
        }
      }
    }

    return IncomeStats(
      totalIncome: totalIncome,
      todayIncome: todayIncome,
      weekIncome: weekIncome,
      monthIncome: monthIncome,
      paymentBreakdown: PaymentMethodBreakdown(
        efectivo: efectivoTotal,
        yape: yapeTotal,
        plin: plinTotal,
        transferencia: transferenciaTotal,
      ),
    );
  }

  PeakHoursStats _calculatePeakHoursStats(List<BookingModel> bookings) {
    Map<int, int> hourlyCount = {};

    for (var booking in bookings) {
      final hour = booking.startTime.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }

    final hourlyBookings = hourlyCount.entries
        .map((entry) => HourlyBooking(hour: entry.key, count: entry.value))
        .toList()
      ..sort((a, b) => a.hour.compareTo(b.hour));

    return PeakHoursStats(hourlyBookings: hourlyBookings);
  }
}

// Clase auxiliar para agrupar datos diarios
class DailyBookingData {
  int count;
  double hours;

  DailyBookingData({required this.count, required this.hours});
}
