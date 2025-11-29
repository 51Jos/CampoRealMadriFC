import 'package:url_launcher/url_launcher.dart';
import '../../features/booking/domain/entities/booking.dart';

/// Servicio para enviar mensajes por WhatsApp
class WhatsAppService {
  /// Envía un mensaje de confirmación de reserva por WhatsApp
  Future<bool> sendBookingConfirmation(Booking booking, {String? mapsLink}) async {
    if (booking.userPhone == null) return false;

    final message = _buildConfirmationMessage(booking, mapsLink);
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
  String _buildConfirmationMessage(Booking booking, [String? mapsLink]) {
    final date = booking.date;

    // Formatear fecha con nombre del día y mes
    final weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
                    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final dateStr = '$weekday, ${date.day} $month ${date.year}';

    // Formatear hora de inicio y fin
    final startHour = booking.startTime.hour.toString().padLeft(2, '0');
    final endHour = booking.endTime.hour.toString().padLeft(2, '0');
    final timeStr = '$startHour:00 - $endHour:00';

    // Generar código de reserva (últimos 8 caracteres del ID en mayúsculas)
    final code = '#${booking.id.toUpperCase().substring(booking.id.length > 8 ? booking.id.length - 8 : 0)}';

    return '''
⚽ *RESERVA CONFIRMADA* ⚽

📍 *Campo:* Campo Deportivo Real Madrid FC
📅 *Fecha:* $dateStr
⏰ *Hora:* $timeStr
⏱️ *Duración:* ${booking.durationHours} hora${booking.durationHours > 1 ? 's' : ''}
💰 *Total:* S/ ${booking.totalPrice.toStringAsFixed(2)}

📍 *Dirección:* Lima, Perú
🆔 *Código:* $code

📱 *Contacto:* 918817238
📍 *Cómo llegar:* ${mapsLink ?? 'https://maps.google.com'}

¡Nos vemos en la cancha! 🎉
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

      // Usar https://wa.me/ que funciona en iOS, Android y Web
      // Este enlace abre WhatsApp app si está instalada o WhatsApp Web si no
      final url = Uri.parse('https://wa.me/$phoneWithCountryCode?text=$encodedMessage');

      // Intentar abrir WhatsApp
      final canLaunch = await canLaunchUrl(url);
      print('Can launch WhatsApp URL: $canLaunch');

      if (canLaunch) {
        // LaunchMode.externalApplication funciona mejor en todas las plataformas
        // En iOS y Android abre WhatsApp app, en Web abre WhatsApp Web en nueva pestaña
        final result = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        print('Launch result: $result');
        return result;
      } else {
        print('Cannot launch WhatsApp URL');
        throw Exception('No se puede abrir WhatsApp');
      }
    } catch (e) {
      print('Error al enviar mensaje por WhatsApp: $e');
      return false;
    }
  }
}
