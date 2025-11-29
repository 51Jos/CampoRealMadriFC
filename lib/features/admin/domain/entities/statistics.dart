import 'package:equatable/equatable.dart';

class Statistics extends Equatable {
  final BookingStats bookingStats;
  final IncomeStats incomeStats;
  final PeakHoursStats peakHoursStats;

  const Statistics({
    required this.bookingStats,
    required this.incomeStats,
    required this.peakHoursStats,
  });

  @override
  List<Object?> get props => [bookingStats, incomeStats, peakHoursStats];
}

class BookingStats extends Equatable {
  final int todayBookings;
  final int weekBookings;
  final int monthBookings;
  final double todayHours;
  final double weekHours;
  final double monthHours;
  final List<DailyBooking> dailyBookings; // Para gráficos de la semana

  const BookingStats({
    required this.todayBookings,
    required this.weekBookings,
    required this.monthBookings,
    required this.todayHours,
    required this.weekHours,
    required this.monthHours,
    required this.dailyBookings,
  });

  @override
  List<Object?> get props => [
        todayBookings,
        weekBookings,
        monthBookings,
        todayHours,
        weekHours,
        monthHours,
        dailyBookings,
      ];
}

class DailyBooking extends Equatable {
  final DateTime date;
  final int count;
  final double hours;

  const DailyBooking({
    required this.date,
    required this.count,
    required this.hours,
  });

  @override
  List<Object?> get props => [date, count, hours];
}

class IncomeStats extends Equatable {
  final double totalIncome;
  final double todayIncome;
  final double weekIncome;
  final double monthIncome;
  final PaymentMethodBreakdown paymentBreakdown;

  const IncomeStats({
    required this.totalIncome,
    required this.todayIncome,
    required this.weekIncome,
    required this.monthIncome,
    required this.paymentBreakdown,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        todayIncome,
        weekIncome,
        monthIncome,
        paymentBreakdown,
      ];
}

class PaymentMethodBreakdown extends Equatable {
  final double efectivo;
  final double yape;
  final double plin;
  final double transferencia;

  const PaymentMethodBreakdown({
    required this.efectivo,
    required this.yape,
    required this.plin,
    required this.transferencia,
  });

  double get total => efectivo + yape + plin + transferencia;

  @override
  List<Object?> get props => [efectivo, yape, plin, transferencia];
}

class PeakHoursStats extends Equatable {
  final List<HourlyBooking> hourlyBookings;

  const PeakHoursStats({
    required this.hourlyBookings,
  });

  List<HourlyBooking> get topHours {
    final sorted = List<HourlyBooking>.from(hourlyBookings)
      ..sort((a, b) => b.count.compareTo(a.count));
    return sorted.take(5).toList();
  }

  @override
  List<Object?> get props => [hourlyBookings];
}

class HourlyBooking extends Equatable {
  final int hour; // 0-23
  final int count;

  const HourlyBooking({
    required this.hour,
    required this.count,
  });

  String get hourLabel {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  @override
  List<Object?> get props => [hour, count];
}
