/// Extensiones útiles para String
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Verifica si es un email válido
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Verifica si es un teléfono peruano válido
  bool get isValidPeruvianPhone {
    final phoneRegex = RegExp(r'^(\+51)?[9][0-9]{8}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'\s'), ''));
  }

  /// Verifica si es un DNI válido
  bool get isValidDNI {
    return length == 8 && int.tryParse(this) != null;
  }

  /// Remueve espacios en blanco extras
  String get trimAll {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
