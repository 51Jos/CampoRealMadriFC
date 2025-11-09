import 'package:equatable/equatable.dart';

/// Entidad que representa una reserva
class Booking extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime startTime;
  final int durationHours;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  DateTime get endTime => startTime.add(Duration(hours: durationHours));

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        startTime,
        durationHours,
        totalPrice,
        status,
        createdAt,
      ];
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}
