import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_detail_panel.dart';
import '../widgets/booking_filter_chips.dart';
import '../widgets/compact_booking_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/responsive_constants.dart';

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
  Booking? _selectedBooking;

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
          final breakpoint = ResponsiveUtils.getBreakpoint(constraints.maxWidth);

          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              if (state is BookingLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is BookingError) {
                return _buildErrorState(state.message, breakpoint);
              }

              if (state is UserBookingsLoaded) {
                final filteredBookings = _filterBookings(state.bookings);

                return Column(
                  children: [
                    BookingFilterChips(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                          // Reset selected booking when filter changes
                          if (_selectedBooking != null &&
                              !filteredBookings.contains(_selectedBooking)) {
                            _selectedBooking = null;
                          }
                        });
                      },
                      breakpoint: breakpoint,
                    ),
                    Expanded(
                      child: filteredBookings.isEmpty
                          ? _buildEmptyState(breakpoint)
                          : _buildBookingsContent(filteredBookings, breakpoint),
                    ),
                  ],
                );
              }

              return _buildEmptyState(breakpoint);
            },
          );
        },
      ),
    );
  }

  // ============================================================================
  // FILTRADO DE RESERVAS
  // ============================================================================

  List<Booking> _filterBookings(List<Booking> bookings) {
    if (_selectedFilter == null) return bookings;
    return bookings.where((b) => b.status == _selectedFilter).toList();
  }

  // ============================================================================
  // CONSTRUCCIÓN DE CONTENIDO SEGÚN BREAKPOINT
  // ============================================================================

  Widget _buildBookingsContent(List<Booking> bookings, ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return _buildMobileView(bookings, breakpoint);
      case ScreenBreakpoint.tablet:
        return _buildTabletView(bookings, breakpoint);
      case ScreenBreakpoint.desktop:
      case ScreenBreakpoint.largeDesktop:
        return _buildDesktopView(bookings, breakpoint);
    }
  }

  // ============================================================================
  // VISTA MÓVIL (Lista vertical)
  // ============================================================================

  Widget _buildMobileView(List<Booking> bookings, ScreenBreakpoint breakpoint) {
    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getSpacing(breakpoint),
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            breakpoint: breakpoint,
            onTap: () => _showBookingDetails(context, booking, breakpoint),
            onCancel: () => _cancelBooking(booking),
            onContact: () => _contactAdmin(),
          );
        },
      ),
    );
  }

  // ============================================================================
  // VISTA TABLET (Grid 2 columnas)
  // ============================================================================

  Widget _buildTabletView(List<Booking> bookings, ScreenBreakpoint breakpoint) {
    final padding = ResponsiveUtils.getPadding(breakpoint);

    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: GridView.builder(
        padding: EdgeInsets.all(padding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            breakpoint: breakpoint,
            onTap: () => _showBookingDetails(context, booking, breakpoint),
            onCancel: () => _cancelBooking(booking),
            onContact: () => _contactAdmin(),
          );
        },
      ),
    );
  }

  // ============================================================================
  // VISTA DESKTOP (Master-Detail)
  // ============================================================================

  Widget _buildDesktopView(List<Booking> bookings, ScreenBreakpoint breakpoint) {
    return Row(
      children: [
        // Panel Master (Lista de reservas)
        SizedBox(
          width: 350,
          child: Column(
            children: [
              // Header del panel Master
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Mis Reservas (${bookings.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Lista de reservas compactas
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return CompactBookingCard(
                      booking: booking,
                      isSelected: _selectedBooking?.id == booking.id,
                      onTap: () {
                        setState(() {
                          _selectedBooking = booking;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Panel Detail (Detalle de reserva seleccionada)
        Expanded(
          child: _selectedBooking == null
              ? _buildNoSelectionState(breakpoint)
              : BookingDetailPanel(
                  booking: _selectedBooking!,
                  onCancel: () => _cancelBooking(_selectedBooking!),
                  onContact: () => _contactAdmin(),
                  onWhatsApp: () => _launchWhatsApp(),
                  onMaps: () => _launchMaps(),
                ),
        ),
      ],
    );
  }

  // ============================================================================
  // ESTADOS VACÍOS Y DE ERROR
  // ============================================================================

  Widget _buildEmptyState(ScreenBreakpoint breakpoint) {
    return EmptyStateWidget(
      icon: Icons.event_busy,
      title: _selectedFilter == null
          ? 'No tienes reservas'
          : 'No hay reservas ${_getFilterName()}',
      message: _selectedFilter == null
          ? 'Tus reservas aparecerán aquí una vez que hagas una'
          : 'Intenta cambiar el filtro para ver otras reservas',
      breakpoint: breakpoint,
    );
  }

  Widget _buildNoSelectionState(ScreenBreakpoint breakpoint) {
    return EmptyStateWidget(
      icon: Icons.touch_app,
      title: 'Selecciona una reserva',
      message: 'Elige una reserva de la lista para ver sus detalles',
      breakpoint: breakpoint,
    );
  }

  Widget _buildErrorState(String message, ScreenBreakpoint breakpoint) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Error',
      message: message,
      breakpoint: breakpoint,
      actionLabel: 'Reintentar',
      onAction: _loadBookings,
    );
  }

  String _getFilterName() {
    switch (_selectedFilter) {
      case BookingStatus.pending:
        return 'pendientes';
      case BookingStatus.confirmed:
        return 'confirmadas';
      case BookingStatus.cancelled:
        return 'canceladas';
      case BookingStatus.completed:
        return 'completadas';
      default:
        return '';
    }
  }

  // ============================================================================
  // ACCIONES
  // ============================================================================

  void _showBookingDetails(BuildContext context, Booking booking, ScreenBreakpoint breakpoint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BookingDetailPanel(
            booking: booking,
            onCancel: () {
              Navigator.pop(context);
              _cancelBooking(booking);
            },
            onContact: () {
              Navigator.pop(context);
              _contactAdmin();
            },
            onWhatsApp: () => _launchWhatsApp(),
            onMaps: () => _launchMaps(),
          ),
        ),
      ),
    );
  }

  void _cancelBooking(Booking booking) {
    // Validar que falten al menos 5 horas para la reserva
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      booking.startTime.hour,
      booking.startTime.minute,
    );
    final hoursUntilBooking = bookingDateTime.difference(now).inHours;

    if (hoursUntilBooking < 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No se puede cancelar'),
          content: Text(
            'Las reservas deben cancelarse con al menos 5 horas de anticipación.\n\n'
            'Tu reserva es en ${hoursUntilBooking > 0 ? "$hoursUntilBooking horas" : "menos de 1 hora"}.\n\n'
            'Para cancelaciones de último momento, por favor contacta al administrador.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _contactAdmin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Contactar Admin'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, volver'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingBloc>().add(CancelBookingEvent(booking.id));

              // Clear selection if it was the cancelled booking
              if (_selectedBooking?.id == booking.id) {
                setState(() {
                  _selectedBooking = null;
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reserva cancelada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _contactAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contactando con el administrador...'),
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '51999999999'; // Número del negocio
    final url = Uri.parse('https://wa.me/$phoneNumber');

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

  Future<void> _launchMaps() async {
    // Coordenadas del Real Madrid Café Lima (ejemplo)
    const latitude = -12.0464;
    const longitude = -77.0428;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

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
