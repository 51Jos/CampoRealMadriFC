import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/time_slot.dart';

/// Modelo de datos para TimeSlot
class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.id,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    required super.pricePerHour,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      isAvailable: json['isAvailable'] as bool,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isAvailable': isAvailable,
      'pricePerHour': pricePerHour,
    };
  }
}
