import 'package:intl/intl.dart';

/// Formateadores reutilizables
class Formatters {
  Formatters._();

  /// Formatea un número como moneda peruana
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'S/. ',
      decimalDigits: 2,
      locale: 'es_PE',
    );
    return formatter.format(amount);
  }

  /// Formatea una fecha
  static String date(DateTime date, {String format = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(format, 'es');
    return formatter.format(date);
  }

  /// Formatea fecha y hora
  static String dateTime(DateTime dateTime, {String format = 'dd/MM/yyyy HH:mm'}) {
    final formatter = DateFormat(format, 'es');
    return formatter.format(dateTime);
  }

  /// Formatea un número de teléfono peruano
  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 9) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    return phone;
  }

  /// Formatea un DNI
  static String dni(String dni) {
    final cleaned = dni.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5)}';
    }
    return dni;
  }

  /// Capitaliza la primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra
  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }
}
