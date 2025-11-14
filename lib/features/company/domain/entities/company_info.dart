import 'package:equatable/equatable.dart';

/// Información de la empresa (cancha sintética)
class CompanyInfo extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String yapeNumber;
  final List<BankAccount> bankAccounts;
  final int startHour; // Hora de inicio (0-23)
  final int endHour; // Hora de fin (0-23)
  final double dayPrice; // Precio por hora de día
  final double nightPrice; // Precio por hora de noche
  final int nightStartHour; // Hora en que empieza tarifa nocturna (ej: 18)
  final DateTime updatedAt;

  const CompanyInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.yapeNumber,
    required this.bankAccounts,
    required this.startHour,
    required this.endHour,
    required this.dayPrice,
    required this.nightPrice,
    required this.nightStartHour,
    required this.updatedAt,
  });

  /// Obtiene el link de Google Maps
  String get googleMapsLink =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  /// Obtiene el precio según la hora
  double getPriceForHour(int hour) {
    return hour >= nightStartHour ? nightPrice : dayPrice;
  }

  /// Formatea la información de cuentas bancarias para compartir
  String get bankAccountsFormatted {
    if (bankAccounts.isEmpty) return 'No disponible';
    return bankAccounts
        .map((account) => '${account.bankName}: ${account.accountNumber} (${account.accountType})')
        .join('\n');
  }

  /// Obtiene el horario formateado
  String get scheduleFormatted {
    String formatHour(int hour) {
      if (hour == 0) return '12:00 AM';
      if (hour < 12) return '$hour:00 AM';
      if (hour == 12) return '12:00 PM';
      return '${hour - 12}:00 PM';
    }
    return '${formatHour(startHour)} - ${formatHour(endHour)}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        latitude,
        longitude,
        phoneNumber,
        yapeNumber,
        bankAccounts,
        startHour,
        endHour,
        dayPrice,
        nightPrice,
        nightStartHour,
        updatedAt,
      ];
}

/// Cuenta bancaria para recibir pagos
class BankAccount extends Equatable {
  final String bankName;
  final String accountNumber;
  final String accountType; // Ej: "Ahorros", "Corriente"
  final String? accountHolderName;

  const BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    this.accountHolderName,
  });

  @override
  List<Object?> get props => [
        bankName,
        accountNumber,
        accountType,
        accountHolderName,
      ];
}
