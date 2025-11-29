import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/domain/entities/payment.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

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
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        // Buscar la reserva actualizada en el estado
        Booking currentBooking = booking;
        if (state is AdminBookingsLoaded) {
          final updatedBooking = state.bookings.firstWhere(
            (b) => b.id == booking.id,
            orElse: () => booking,
          );
          currentBooking = updatedBooking;
        }

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
            child: _buildContent(context, currentBooking),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Booking booking) {
    return Column(
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
            const SizedBox(height: 24),

            // Información de pagos
            _buildPaymentSection(context, booking),

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
              if (_isBookingExpired(booking))
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Esta reserva ya pasó su horario. No se puede confirmar ni rechazar.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
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
              ],
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

  bool _isBookingExpired(Booking booking) {
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      booking.startTime.hour,
      booking.startTime.minute,
    );
    return bookingDateTime.isBefore(now);
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

  Widget _buildPaymentSection(BuildContext context, Booking booking) {
    final totalPaid = booking.totalPaid;
    final remaining = booking.remainingBalance;
    final isFullyPaid = booking.isFullyPaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pagos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isFullyPaid)
              ElevatedButton.icon(
                onPressed: () => _showAddPaymentDialog(context, booking),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Registrar Pago'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
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
            children: [
              // Resumen de pagos
              _buildInfoRow('Total', 'S/ ${booking.totalPrice.toStringAsFixed(2)}'),
              _buildInfoRow(
                'Pagado',
                'S/ ${totalPaid.toStringAsFixed(2)}',
              ),
              _buildInfoRow(
                'Pendiente',
                'S/ ${remaining.toStringAsFixed(2)}',
              ),

              if (isFullyPaid) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Pagado completamente',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Lista de pagos
              if (booking.payments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Detalle de pagos',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ...booking.payments.map((payment) => _buildPaymentItem(payment)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    final date = payment.timestamp;
    final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.method.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                'S/ ${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (payment.method == PaymentMethod.efectivo && payment.cashReceived != null) ...[
            const SizedBox(height: 4),
            Text(
              'Recibido: S/ ${payment.cashReceived!.toStringAsFixed(2)} | Vuelto: S/ ${payment.change!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminBloc>(),
        child: _AddPaymentDialog(booking: booking),
      ),
    );
  }
}

/// Dialog para agregar un pago
class _AddPaymentDialog extends StatefulWidget {
  final Booking booking;

  const _AddPaymentDialog({required this.booking});

  @override
  State<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<_AddPaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.efectivo;
  final _amountController = TextEditingController();
  String? _changeMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    if (_selectedMethod != PaymentMethod.efectivo) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final remaining = widget.booking.remainingBalance;

    if (amount > remaining) {
      final change = amount - remaining;
      setState(() {
        _changeMessage = 'Vuelto a dar: S/ ${change.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        _changeMessage = null;
      });
    }
  }

  void _handleSubmit(BuildContext context) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final remaining = widget.booking.remainingBalance;

    // Para efectivo, el monto puede ser mayor (se da vuelto)
    // Para otros métodos, no puede ser mayor al pendiente
    if (_selectedMethod != PaymentMethod.efectivo && amount > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El monto no puede ser mayor al pendiente (S/ ${remaining.toStringAsFixed(2)})'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? cashReceived;
    double? change;
    double paymentAmount = amount;

    if (_selectedMethod == PaymentMethod.efectivo) {
      // Si el monto es mayor al pendiente, se registra el pendiente y se calcula vuelto
      if (amount > remaining) {
        cashReceived = amount;
        change = amount - remaining;
        paymentAmount = remaining; // Solo se registra el monto pendiente como pago
      }
    }

    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: _selectedMethod,
      amount: paymentAmount,
      timestamp: DateTime.now(),
      cashReceived: cashReceived,
      change: change,
    );

    context.read<AdminBloc>().add(AddPaymentEvent(
          bookingId: widget.booking.id,
          payment: payment,
        ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.booking.remainingBalance;

    return AlertDialog(
      title: const Text('Registrar Pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monto pendiente: S/ ${remaining.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Método de pago
            const Text(
              'Método de pago',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                  _changeMessage = null;
                  _amountController.clear();
                });
              },
            ),
            const SizedBox(height: 16),

            // Monto del pago
            Text(
              _selectedMethod == PaymentMethod.efectivo
                ? 'Monto recibido del cliente'
                : 'Monto del pago',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: 'S/ ',
                hintText: '0.00',
              ),
              onChanged: (_) {
                if (_selectedMethod == PaymentMethod.efectivo) {
                  _calculateChange();
                }
              },
            ),

            // Mensaje de vuelto para efectivo
            if (_selectedMethod == PaymentMethod.efectivo && _changeMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _changeMessage!,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _handleSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
