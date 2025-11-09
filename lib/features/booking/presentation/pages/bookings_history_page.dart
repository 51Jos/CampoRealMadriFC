import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'booking_confirmation_page.dart';

class BookingsHistoryPage extends StatefulWidget {
  final bool skipInitialLoad;

  const BookingsHistoryPage({
    super.key,
    this.skipInitialLoad = false,
  });

  @override
  State<BookingsHistoryPage> createState() => _BookingsHistoryPageState();
}

class _BookingsHistoryPageState extends State<BookingsHistoryPage> {
  BookingStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    if (!widget.skipInitialLoad) {
      _loadBookings();
    }
  }

  void _loadBookings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingBloc>().add(LoadUserBookingsEvent(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              if (state is BookingLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is BookingError) {
                return _buildErrorState(state.message, constraints.maxWidth);
              }

              if (state is UserBookingsLoaded) {
                final filteredBookings = _filterBookings(state.bookings);

                return Column(
                  children: [
                    _buildFilterChips(constraints.maxWidth),
                    Expanded(
                      child: filteredBookings.isEmpty
                          ? _buildEmptyState(constraints.maxWidth)
                          : _buildBookingsList(filteredBookings, constraints.maxWidth),
                    ),
                  ],
                );
              }

              return _buildEmptyState(constraints.maxWidth);
            },
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

  double _getTitleFontSize(double width) {
    if (width < 360) return 18;
    if (width < 600) return 20;
    return 22;
  }

  double _getSubtitleFontSize(double width) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    return 18;
  }

  double _getBodyFontSize(double width) {
    if (width < 360) return 12;
    if (width < 600) return 14;
    return 14;
  }

  double _getButtonFontSize(double width) {
    if (width < 360) return 11;
    if (width < 600) return 12;
    return 13;
  }

  double _getIconSize(double width) {
    if (width < 360) return 64;
    if (width < 600) return 80;
    return 96;
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    final now = DateTime.now();
    final futureBookings = bookings.where((booking) {
      final bookingEndTime = booking.startTime.add(Duration(hours: booking.durationHours));
      return bookingEndTime.isAfter(now);
    }).toList();

    if (_selectedFilter == null) {
      return futureBookings;
    }
    return futureBookings.where((b) => b.status == _selectedFilter).toList();
  }

  Widget _buildErrorState(String message, double width) {
    final iconSize = _getIconSize(width);
    final titleSize = _getSubtitleFontSize(width);
    final bodySize = _getBodyFontSize(width);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_getHorizontalPadding(width)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: iconSize, color: Colors.red.shade300),
            SizedBox(height: _getHorizontalPadding(width)),
            Text(
              'Error al cargar reservas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: titleSize, color: Colors.grey.shade600),
            ),
            SizedBox(height: _getHorizontalPadding(width) * 0.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: bodySize, color: Colors.grey.shade500),
            ),
            SizedBox(height: _getHorizontalPadding(width) * 1.5),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(double width) {
    final padding = _getHorizontalPadding(width);
    final fontSize = _getButtonFontSize(width);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.75),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: padding * 0.5,
          children: [
            _buildFilterChip('Todas', null, Icons.list, fontSize),
            _buildFilterChip('Pendientes', BookingStatus.pending, Icons.access_time, fontSize),
            _buildFilterChip('Confirmadas', BookingStatus.confirmed, Icons.check_circle, fontSize),
            _buildFilterChip('Canceladas', BookingStatus.cancelled, Icons.cancel, fontSize),
            _buildFilterChip('Completadas', BookingStatus.completed, Icons.done_all, fontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, BookingStatus? status, IconData icon, double fontSize) {
    final isSelected = _selectedFilter == status;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState(double width) {
    final iconSize = _getIconSize(width);
    final titleSize = _getTitleFontSize(width);
    final bodySize = _getBodyFontSize(width);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_getHorizontalPadding(width)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: iconSize, color: Colors.grey.shade300),
            SizedBox(height: _getHorizontalPadding(width)),
            Text(
              'No hay reservas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: _getHorizontalPadding(width) * 0.5),
            Text(
              _selectedFilter != null
                  ? 'No hay reservas con este estado'
                  : 'Aún no has realizado ninguna reserva',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: bodySize, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, double width) {
    final padding = _getHorizontalPadding(width);

    return RefreshIndicator(
      onRefresh: () async {
        _loadBookings();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index], width);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, double width) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');
    final timeFormat = DateFormat('h:mm a', 'es');
    final padding = _getHorizontalPadding(width);
    final titleSize = _getBodyFontSize(width) + 2;
    final bodySize = _getBodyFontSize(width);
    final buttonSize = _getButtonFontSize(width);

    return Card(
      margin: EdgeInsets.only(bottom: padding),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header con estado
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(booking.status),
                      color: _getStatusColor(booking.status),
                      size: 20,
                    ),
                    SizedBox(width: padding * 0.5),
                    Text(
                      _getStatusLabel(booking.status),
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.bold,
                        fontSize: bodySize,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 0.5,
                    vertical: padding * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${booking.id.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontSize: bodySize - 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detalles
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: padding * 0.5),
                    Expanded(
                      child: Text(
                        dateFormat.format(booking.date),
                        style: TextStyle(
                          fontSize: bodySize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding * 0.5),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: padding * 0.5),
                    Text(
                      '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                      style: TextStyle(fontSize: bodySize),
                    ),
                  ],
                ),
                SizedBox(height: padding * 0.5),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: padding * 0.5),
                    Text(
                      '${booking.durationHours} ${booking.durationHours == 1 ? 'hora' : 'horas'}',
                      style: TextStyle(fontSize: bodySize),
                    ),
                  ],
                ),
                SizedBox(height: padding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: titleSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'S/ ${booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: titleSize + 4,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),

                // Botones de acción
                SizedBox(height: padding),
                const Divider(),
                SizedBox(height: padding * 0.5),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewBookingDetails(booking),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text('Ver', style: TextStyle(fontSize: buttonSize)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                        ),
                      ),
                    ),
                    SizedBox(width: padding * 0.5),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareOnWhatsApp(booking),
                        icon: const Icon(Icons.share, size: 16),
                        label: Text('Compartir', style: TextStyle(fontSize: buttonSize)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding * 0.5),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openGoogleMaps,
                        icon: const Icon(Icons.location_on, size: 16),
                        label: Text('Cómo llegar', style: TextStyle(fontSize: buttonSize)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                        ),
                      ),
                    ),
                    if (booking.status == BookingStatus.pending ||
                        booking.status == BookingStatus.confirmed) ...[
                      SizedBox(width: padding * 0.5),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(booking),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: Text('Cancelar', style: TextStyle(fontSize: buttonSize)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.access_time;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.completed:
        return Icons.done_all;
    }
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.completed:
        return 'Completada';
    }
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro que deseas cancelar esta reserva?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Booking booking) {
    context.read<BookingBloc>().add(CancelBookingEvent(booking.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reserva cancelada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _loadBookings();
    });
  }

  void _viewBookingDetails(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationPage(booking: booking),
      ),
    );
  }

  void _shareOnWhatsApp(Booking booking) async {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');
    final timeFormat = DateFormat('h:mm a', 'es');

    final message = '''
🏟️ *Reserva Real Madrid FC - Campo Sintético*

📅 Fecha: ${dateFormat.format(booking.date)}
⏰ Horario: ${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.startTime.add(Duration(hours: booking.durationHours)))}
⏱️ Duración: ${booking.durationHours} ${booking.durationHours == 1 ? 'hora' : 'horas'}
💰 Total: S/ ${booking.totalPrice.toStringAsFixed(2)}
📋 Estado: ${_getStatusLabel(booking.status)}
🆔 Código: #${booking.id.substring(0, 8).toUpperCase()}

📍 *Ubicación:* Real Madrid FC - Lima
''';

    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openGoogleMaps() async {
    const lat = -12.0464;
    const lng = -77.0428;

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
