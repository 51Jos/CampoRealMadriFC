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
  final String? rejectionReason;
  final String? userName;
  final String? userPhone;
  final String? userEmail;

  const Booking({
    required this.id,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.userName,
    this.userPhone,
    this.userEmail,
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
        rejectionReason,
        userName,
        userPhone,
        userEmail,
      ];
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}
