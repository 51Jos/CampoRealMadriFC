import 'package:equatable/equatable.dart';

/// Métodos de pago disponibles
enum PaymentMethod {
  yape('Yape'),
  plin('Plin'),
  transferencia('Transferencia'),
  efectivo('Efectivo');

  final String displayName;
  const PaymentMethod(this.displayName);
}

/// Entidad de pago para una reserva
class Payment extends Equatable {
  final String id;
  final PaymentMethod method;
  final double amount;
  final DateTime timestamp;
  final double? cashReceived; // Solo para efectivo, cuánto dio el cliente
  final double? change; // Solo para efectivo, el vuelto

  const Payment({
    required this.id,
    required this.method,
    required this.amount,
    required this.timestamp,
    this.cashReceived,
    this.change,
  });

  @override
  List<Object?> get props => [id, method, amount, timestamp, cashReceived, change];

  Payment copyWith({
    String? id,
    PaymentMethod? method,
    double? amount,
    DateTime? timestamp,
    double? cashReceived,
    double? change,
  }) {
    return Payment(
      id: id ?? this.id,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      cashReceived: cashReceived ?? this.cashReceived,
      change: change ?? this.change,
    );
  }
}
