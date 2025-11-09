import '../constants/app_strings.dart';

/// Validadores reutilizables para formularios
class Validators {
  Validators._();

  /// Valida que un campo no esté vacío
  static String? required(String? value, [String? customMessage]) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? AppStrings.requiredField;
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  /// Valida formato de teléfono peruano
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;

    final phoneRegex = RegExp(r'^(\+51)?[9][0-9]{8}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min) {
      return customMessage ?? 'Mínimo $min caracteres';
    }
    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int max, [String? customMessage]) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return customMessage ?? 'Máximo $max caracteres';
    }
    return null;
  }

  /// Combina múltiples validadores
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
