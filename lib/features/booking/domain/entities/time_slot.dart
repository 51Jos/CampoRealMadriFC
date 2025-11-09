import 'package:equatable/equatable.dart';

/// Entidad que representa un horario disponible
class TimeSlot extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final double pricePerHour;

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.pricePerHour,
  });

  @override
  List<Object?> get props => [id, startTime, endTime, isAvailable, pricePerHour];
}
