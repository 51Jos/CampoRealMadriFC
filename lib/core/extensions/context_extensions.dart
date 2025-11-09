import 'package:flutter/material.dart';

/// Extensiones útiles para BuildContext
extension ContextExtensions on BuildContext {
  /// Acceso rápido al Theme
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido a TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Acceso rápido a ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Acceso rápido a MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Tamaño de la pantalla
  Size get screenSize => mediaQuery.size;

  /// Ancho de la pantalla
  double get screenWidth => screenSize.width;

  /// Alto de la pantalla
  double get screenHeight => screenSize.height;

  /// Verifica si es un dispositivo pequeño
  bool get isSmallScreen => screenWidth < 600;

  /// Verifica si es una tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Verifica si es desktop
  bool get isDesktop => screenWidth >= 900;

  /// Muestra un SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Muestra un SnackBar de error
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.error,
    );
  }

  /// Muestra un SnackBar de éxito
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Cierra el teclado
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
