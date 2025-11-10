import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking.dart';

/// Modelo de datos para Booking
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.startTime,
    required super.durationHours,
    required super.totalPrice,
    required super.status,
    required super.createdAt,
    super.rejectionReason,
    super.userName,
    super.userPhone,
    super.userEmail,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      startTime: (json['startTime'] as Timestamp).toDate(),
      durationHours: json['durationHours'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      rejectionReason: json['rejectionReason'] as String?,
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'rejectionReason': rejectionReason,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
    };
  }
}
