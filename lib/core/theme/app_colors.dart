import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación - Real Madrid FC
class AppColors {
  AppColors._();

  // Colores corporativos Real Madrid FC
  static const Color primary = Color(0xFF001F54); // Azul marino corporativo
  static const Color primaryDark = Color(0xFF001233);
  static const Color primaryLight = Color(0xFF003D7A);

  static const Color secondary = Color(0xFFFFD700); // Dorado
  static const Color secondaryDark = Color(0xFFDAA520);
  static const Color secondaryLight = Color(0xFFFFE44D);

  static const Color accent = Color(0xFF00A651); // Verde campo

  // Estados
  static const Color success = Color(0xFF00A651);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF0288D1);

  // Neutros
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Colores adicionales para la app
  static const Color fieldGreen = Color(0xFF00A651); // Verde césped
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fieldGradient = LinearGradient(
    colors: [Color(0xFF00A651), Color(0xFF008C44)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
