import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/domain/entities/booking.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

/// Página de detalle de reserva para móvil/tablet
class AdminBookingDetailPage extends StatelessWidget {
  final Booking booking;
  final _whatsappService = WhatsAppService();

  AdminBookingDetailPage({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'Detalle de Reserva',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado
            Center(
              child: _buildStatusChip(booking.status),
            ),
            const SizedBox(height: 24),

            // Información del cliente
            _buildSection(
              'Cliente',
              [
                _buildInfoRow('Nombre', booking.userName ?? 'No disponible'),
                _buildInfoRow('Email', booking.userEmail ?? 'No disponible'),
                _buildInfoRow('Teléfono', booking.userPhone ?? 'No disponible'),
              ],
            ),
            const SizedBox(height: 24),

            // Información de la reserva
            _buildSection(
              'Reserva',
              [
                _buildInfoRow(
                  'Fecha',
                  '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                ),
                _buildInfoRow('Hora', '${booking.startTime.hour}:00'),
                _buildInfoRow('Duración', '${booking.durationHours}h'),
                _buildInfoRow('Total', 'S/ ${booking.totalPrice.toStringAsFixed(2)}'),
              ],
            ),

            if (booking.rejectionReason != null) ...[
              const SizedBox(height: 24),
              _buildSection(
                'Motivo de Rechazo',
                [
                  Text(
                    booking.rejectionReason!,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Acciones
            if (booking.status == BookingStatus.pending) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminBloc>().add(ConfirmBookingEvent(booking.id));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRejectDialog(context, booking),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Rechazar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botón de WhatsApp
            if (booking.userPhone != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _sendWhatsAppMessage(context, booking),
                  icon: const Icon(Icons.chat),
                  label: const Text('Enviar mensaje por WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        label = 'Confirmada';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Cancelada';
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        label = 'Completada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Booking booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rechazar Reserva'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              hintText: 'Ej: Horario no disponible',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  context.read<AdminBloc>().add(RejectBookingEvent(
                        bookingId: booking.id,
                        reason: reasonController.text.trim(),
                      ));
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, Booking booking) async {
    // Mostrar dialog para elegir el tipo de mensaje
    final messageType = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enviar mensaje por WhatsApp'),
          content: const Text('¿Qué tipo de mensaje deseas enviar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            if (booking.status == BookingStatus.confirmed)
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, 'confirmation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmación'),
              ),
            if (booking.status == BookingStatus.cancelled)
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, 'rejection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Rechazo'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, 'custom'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Personalizado'),
            ),
          ],
        );
      },
    );

    if (messageType == null || !context.mounted) return;

    bool success = false;

    if (messageType == 'confirmation') {
      success = await _whatsappService.sendBookingConfirmation(booking);
    } else if (messageType == 'rejection') {
      success = await _whatsappService.sendBookingRejection(booking);
    } else if (messageType == 'custom') {
      final customMessage = await _showCustomMessageDialog(context);
      if (customMessage != null && booking.userPhone != null) {
        success = await _whatsappService.sendCustomMessage(
          booking.userPhone!,
          customMessage,
        );
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'WhatsApp abierto correctamente'
                : 'Error al abrir WhatsApp',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<String?> _showCustomMessageDialog(BuildContext context) async {
    final messageController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mensaje personalizado'),
          content: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: 'Mensaje',
              hintText: 'Escribe tu mensaje aquí...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, messageController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
