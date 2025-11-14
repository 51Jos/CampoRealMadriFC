import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/dependency_injection/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../company/domain/entities/company_info.dart';
import '../../../company/domain/usecases/get_company_info.dart';
import '../../domain/entities/booking.dart';

class BookingConfirmationPage extends StatefulWidget {
  final Booking booking;

  const BookingConfirmationPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  CompanyInfo? _companyInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    final getCompanyInfo = sl<GetCompanyInfo>();
    final result = await getCompanyInfo();

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      (companyInfo) {
        if (mounted) {
          setState(() {
            _companyInfo = companyInfo;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Confirmación de Reserva',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_companyInfo == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Confirmación de Reserva',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar información',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'No se pudo cargar la información de la empresa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Confirmación de Reserva',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSuccessHeader(constraints.maxWidth),
                _buildBookingDetails(constraints.maxWidth),
                _buildFieldInfo(constraints.maxWidth),
                _buildActionButtons(context, constraints.maxWidth),
              ],
            ),
          );
        },
      ),
    );
  }

  // Métodos para dimensiones responsivas
  double _getHorizontalPadding(double width) {
    if (width < 360) return 12;
    if (width < 600) return 16;
    if (width < 900) return 20;
    return 24;
  }

  double _getHeaderPadding(double width) {
    if (width < 360) return 24;
    if (width < 600) return 32;
    return 40;
  }

  double _getIconSize(double width) {
    if (width < 360) return 56;
    if (width < 600) return 64;
    return 72;
  }

  double _getTitleFontSize(double width) {
    if (width < 360) return 24;
    if (width < 600) return 28;
    return 32;
  }

  double _getSubtitleFontSize(double width) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    return 18;
  }

  double _getSectionTitleSize(double width) {
    if (width < 360) return 18;
    if (width < 600) return 20;
    return 22;
  }

  double _getBodyFontSize(double width) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    return 16;
  }

  Widget _buildSuccessHeader(double width) {
    final padding = _getHeaderPadding(width);
    final iconSize = _getIconSize(width);
    final titleSize = _getTitleFontSize(width);
    final subtitleSize = _getSubtitleFontSize(width);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.625),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.accent,
              size: iconSize,
            ),
          ),
          SizedBox(height: padding * 0.75),
          Text(
            '¡Reserva Confirmada!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: padding * 0.25),
          Text(
            'Tu campo ha sido reservado exitosamente',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: subtitleSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(double width) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');
    final padding = _getHorizontalPadding(width);
    final titleSize = _getSectionTitleSize(width);

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding * 1.25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de la Reserva',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: padding * 1.25),
          _buildDetailRow(
            Icons.calendar_today,
            'Fecha',
            dateFormat.format(widget.booking.date),
            width,
          ),
          SizedBox(height: padding),
          _buildDetailRow(
            Icons.access_time,
            'Hora',
            '${timeFormat.format(widget.booking.startTime)} - ${timeFormat.format(widget.booking.endTime)}',
            width,
          ),
          SizedBox(height: padding),
          _buildDetailRow(
            Icons.timer,
            'Duración',
            '${widget.booking.durationHours} ${widget.booking.durationHours == 1 ? 'hora' : 'horas'}',
            width,
          ),
          SizedBox(height: padding),
          _buildDetailRow(
            Icons.attach_money,
            'Total',
            'S/ ${widget.booking.totalPrice.toStringAsFixed(2)}',
            width,
          ),
          SizedBox(height: padding),
          _buildDetailRow(
            Icons.confirmation_number,
            'ID de Reserva',
            '#${widget.booking.id.substring(0, 8).toUpperCase()}',
            width,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, double width) {
    final labelSize = _getSubtitleFontSize(width) - 2;
    final valueSize = _getBodyFontSize(width);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInfo(double width) {
    final padding = _getHorizontalPadding(width);
    final titleSize = _getSectionTitleSize(width) - 4;
    final subtitleSize = _getSubtitleFontSize(width) - 2;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      padding: EdgeInsets.all(padding * 1.25),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.75),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              SizedBox(width: padding * 0.75),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _companyInfo!.name,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Campo Sintético',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: padding),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              SizedBox(width: padding * 0.5),
              Expanded(
                child: Text(
                  _companyInfo!.address,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double width) {
    final padding = _getHorizontalPadding(width);
    final fontSize = _getBodyFontSize(width);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _shareOnWhatsApp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text(
                'Compartir por WhatsApp',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: padding * 0.75),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _openGoogleMaps(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.directions, color: AppColors.primary),
              label: Text(
                'Cómo Llegar (Google Maps)',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: padding * 0.75),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Volver al Inicio',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOnWhatsApp(BuildContext context) async {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');

    final message = '''
⚽ *RESERVA CONFIRMADA* ⚽

📍 *Campo:* ${_companyInfo!.name}
📅 *Fecha:* ${dateFormat.format(widget.booking.date)}
⏰ *Hora:* ${timeFormat.format(widget.booking.startTime)} - ${timeFormat.format(widget.booking.endTime)}
⏱️ *Duración:* ${widget.booking.durationHours} ${widget.booking.durationHours == 1 ? 'hora' : 'horas'}
💰 *Total:* S/ ${widget.booking.totalPrice.toStringAsFixed(2)}

📍 *Dirección:* ${_companyInfo!.address}
🆔 *Código:* #${widget.booking.id.substring(0, 8).toUpperCase()}

📱 *Contacto:* ${_companyInfo!.phoneNumber}
📍 *Cómo llegar:* ${_companyInfo!.googleMapsLink}

¡Nos vemos en la cancha! 🎉
    ''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('whatsapp://send?text=$encodedMessage');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openGoogleMaps(BuildContext context) async {
    final url = Uri.parse(_companyInfo!.googleMapsLink);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el mapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
