import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../features/booking/domain/entities/booking.dart';

/// Servicio para enviar mensajes por WhatsApp
class WhatsAppService {
  /// Envía un mensaje de confirmación de reserva por WhatsApp
  Future<bool> sendBookingConfirmation(Booking booking) async {
    if (booking.userPhone == null) return false;

    final message = _buildConfirmationMessage(booking);
    return await _sendWhatsAppMessage(booking.userPhone!, message);
  }

  /// Envía un mensaje de rechazo de reserva por WhatsApp
  Future<bool> sendBookingRejection(Booking booking) async {
    if (booking.userPhone == null) return false;

    final message = _buildRejectionMessage(booking);
    return await _sendWhatsAppMessage(booking.userPhone!, message);
  }

  /// Envía un mensaje personalizado por WhatsApp
  Future<bool> sendCustomMessage(String phone, String message) async {
    return await _sendWhatsAppMessage(phone, message);
  }

  /// Construye el mensaje de confirmación
  String _buildConfirmationMessage(Booking booking) {
    final date = booking.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr = '${booking.startTime.hour}:00';

    return '''
¡Hola ${booking.userName ?? 'Usuario'}! 👋

✅ Tu reserva ha sido *CONFIRMADA*

📅 Fecha: $dateStr
⏰ Hora: $timeStr
⏱️ Duración: ${booking.durationHours}h
💰 Total: S/ ${booking.totalPrice.toStringAsFixed(2)}

¡Te esperamos en la cancha! ⚽

_Sintético Lima_
    ''';
  }

  /// Construye el mensaje de rechazo
  String _buildRejectionMessage(Booking booking) {
    final date = booking.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr = '${booking.startTime.hour}:00';

    return '''
Hola ${booking.userName ?? 'Usuario'} 👋

Lamentamos informarte que tu reserva ha sido *rechazada*.

📅 Fecha solicitada: $dateStr
⏰ Hora solicitada: $timeStr

❌ Motivo: ${booking.rejectionReason ?? 'No especificado'}

Por favor, intenta reservar en otro horario. Estamos a tu disposición para ayudarte.

_Sintético Lima_
    ''';
  }

  /// Envía un mensaje por WhatsApp usando url_launcher
  Future<bool> _sendWhatsAppMessage(String phone, String message) async {
    try {
      // Limpiar el número de teléfono (quitar espacios, guiones, etc.)
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // Si no tiene código de país, agregar +51 (Perú)
      final phoneWithCountryCode = cleanPhone.startsWith('+')
          ? cleanPhone.substring(1) // Quitar el + para el formato
          : '51$cleanPhone';

      // Codificar el mensaje para URL
      final encodedMessage = Uri.encodeComponent(message);

      // Construir URL de WhatsApp
      // Para web usamos wa.me
      // Para mobile (iOS/Android) intentamos primero whatsapp://
      Uri url;
      LaunchMode mode;

      if (kIsWeb) {
        // En web usar wa.me que funciona mejor
        url = Uri.parse('https://wa.me/$phoneWithCountryCode?text=$encodedMessage');
        mode = LaunchMode.platformDefault;
      } else {
        // En mobile usar el esquema whatsapp:// que es más confiable
        url = Uri.parse('whatsapp://send?phone=$phoneWithCountryCode&text=$encodedMessage');
        mode = LaunchMode.externalApplication;
      }

      // Intentar abrir WhatsApp
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: mode,
          webOnlyWindowName: kIsWeb ? '_blank' : null,
        );
      } else {
        // Si falla con whatsapp://, intentar con https://wa.me/ como fallback
        if (!kIsWeb) {
          final fallbackUrl = Uri.parse('https://wa.me/$phoneWithCountryCode?text=$encodedMessage');
          if (await canLaunchUrl(fallbackUrl)) {
            return await launchUrl(
              fallbackUrl,
              mode: LaunchMode.externalApplication,
            );
          }
        }
        throw Exception('No se puede abrir WhatsApp');
      }
    } catch (e) {
      print('Error al enviar mensaje por WhatsApp: $e');
      return false;
    }
  }
}
