import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking.dart';
import 'responsive_constants.dart';
import 'booking_status_utils.dart';

/// Card de reserva para vistas móvil y tablet
class BookingCard extends StatelessWidget {
  final Booking booking;
  final ScreenBreakpoint breakpoint;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onContact;

  const BookingCard({
    super.key,
    required this.booking,
    required this.breakpoint,
    this.onTap,
    this.onCancel,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getPadding(breakpoint);
    final spacing = ResponsiveUtils.getSpacing(breakpoint);
    final titleSize = ResponsiveUtils.getSubtitleSize(breakpoint);
    final bodySize = ResponsiveUtils.getBodySize(breakpoint);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: spacing / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con fecha y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fecha
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: titleSize,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: spacing / 2),
                      Text(
                        DateFormat('dd/MM/yyyy').format(booking.date),
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  // Estado
                  _buildStatusChip(titleSize, bodySize, spacing),
                ],
              ),

              SizedBox(height: spacing),

              // Horario
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: bodySize * 1.2,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: spacing / 2),
                  Text(
                    '${DateFormat('HH:mm').format(booking.startTime)} - '
                    '${DateFormat('HH:mm').format(booking.endTime)}',
                    style: TextStyle(
                      fontSize: bodySize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing / 2,
                      vertical: spacing / 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${booking.durationHours}h',
                      style: TextStyle(
                        fontSize: bodySize * 0.9,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing / 2),

              // Precio
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: bodySize * 1.2,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: spacing / 2),
                  Text(
                    'S/ ${booking.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Acciones si aplican
              if (_shouldShowActions()) ...[
                SizedBox(height: spacing),
                const Divider(height: 1),
                SizedBox(height: spacing / 2),
                _buildActions(bodySize, spacing),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(double titleSize, double bodySize, double spacing) {
    final statusColor = BookingStatusUtils.getStatusColor(booking.status);
    final statusLabel = BookingStatusUtils.getStatusLabel(booking.status);
    final statusIcon = BookingStatusUtils.getStatusIcon(booking.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing / 2,
        vertical: spacing / 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: bodySize,
            color: statusColor,
          ),
          SizedBox(width: spacing / 4),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: bodySize * 0.9,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowActions() {
    return booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.pending;
  }

  Widget _buildActions(double bodySize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botón de contacto
        if (onContact != null)
          TextButton.icon(
            onPressed: onContact,
            icon: Icon(Icons.phone, size: bodySize),
            label: Text(
              'Contactar',
              style: TextStyle(fontSize: bodySize * 0.9),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),

        SizedBox(width: spacing / 2),

        // Botón de cancelar
        if (onCancel != null && booking.status != BookingStatus.cancelled)
          TextButton.icon(
            onPressed: onCancel,
            icon: Icon(Icons.cancel_outlined, size: bodySize),
            label: Text(
              'Cancelar',
              style: TextStyle(fontSize: bodySize * 0.9),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
          ),
      ],
    );
  }
}
