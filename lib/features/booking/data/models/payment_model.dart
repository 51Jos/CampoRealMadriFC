import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';

/// Modelo de pago para la capa de datos
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.method,
    required super.amount,
    required super.timestamp,
    super.cashReceived,
    super.change,
  });

  /// Convierte desde Firestore a modelo
  factory PaymentModel.fromFirestore(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      method: PaymentMethod.values.firstWhere(
        (m) => m.name == json['method'],
        orElse: () => PaymentMethod.efectivo,
      ),
      amount: (json['amount'] as num).toDouble(),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      cashReceived: json['cashReceived'] != null
          ? (json['cashReceived'] as num).toDouble()
          : null,
      change: json['change'] != null
          ? (json['change'] as num).toDouble()
          : null,
    );
  }

  /// Convierte desde entidad a modelo
  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      method: payment.method,
      amount: payment.amount,
      timestamp: payment.timestamp,
      cashReceived: payment.cashReceived,
      change: payment.change,
    );
  }

  /// Convierte a formato Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'method': method.name,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      if (cashReceived != null) 'cashReceived': cashReceived,
      if (change != null) 'change': change,
    };
  }
}
