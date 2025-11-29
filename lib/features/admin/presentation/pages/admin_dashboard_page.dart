import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/presentation/widgets/responsive_constants.dart';
import '../../../company/domain/entities/company_info.dart';
import '../../../company/domain/repositories/company_repository.dart';
import '../../../company/domain/usecases/get_company_info.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'admin_booking_detail_page.dart';

/// Dashboard principal del administrador
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Booking? _selectedBooking;
  String? _currentFilter;
  final _whatsappService = WhatsAppService();
  CompanyInfo? _companyInfo;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
    // Resetear el índice de navegación al volver
    _selectedNavIndex = 0;
  }

  Future<void> _loadCompanyInfo() async {
    final getCompanyInfo = GetCompanyInfo(context.read<CompanyRepository>());
    final result = await getCompanyInfo();
    result.fold(
      (failure) => null,
      (info) {
        if (mounted) {
          setState(() {
            _companyInfo = info;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        // Solo cargar cuando el estado es inicial
        if (state is AdminInitial) {
          context.read<AdminBloc>().add(const LoadAllBookingsEvent());
        }
      },
      builder: (context, state) {
        return ResponsiveLayout(
          mobile: _buildMobileLayout(),
          desktop: _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'Panel de Administrador',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdminBloc>().add(const LoadAllBookingsEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(ScreenBreakpoint.mobile),
          Expanded(child: _buildBookingsList()),
        ],
      ),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await context.push('/admin/create-booking');
                if (result == true && mounted) {
                  context.read<AdminBloc>().add(const LoadAllBookingsEvent());
                }
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Reserva'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            // Ya estamos en reservas, solo actualizar el índice
            setState(() {
              _selectedNavIndex = 0;
            });
          } else if (index == 1) {
            context.push('/admin/statistics').then((_) {
              // Resetear índice al volver
              if (mounted) {
                setState(() {
                  _selectedNavIndex = 0;
                });
              }
            });
          } else if (index == 2) {
            context.push('/admin/company-settings').then((_) {
              // Resetear índice al volver
              if (mounted) {
                setState(() {
                  _selectedNavIndex = 0;
                });
              }
            });
          } else if (index == 3) {
            context.read<AuthBloc>().add(SignOutRequested());
            context.go('/admin/login');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configuración',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/admin/create-booking');
          if (result == true && mounted) {
            context.read<AdminBloc>().add(const LoadAllBookingsEvent());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Reserva'),
      ),
      body: Row(
        children: [
          // NavigationRail lateral
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            backgroundColor: Colors.white,
            elevation: 1,
            labelType: MediaQuery.of(context).size.width > 1200
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 1200) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'Cerrar sesión',
                    onPressed: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                      context.go('/admin/login');
                    },
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Reservas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Estadísticas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Configuración'),
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (index) {
              if (index == 1) {
                context.push('/admin/statistics');
              } else if (index == 2) {
                context.push('/admin/company-settings');
              }
            },
            selectedIconTheme: const IconThemeData(
              color: AppColors.primary,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: Colors.grey.shade600,
              size: 24,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Contenido principal
          Expanded(
            child: MaxWidthContainer(
              maxWidth: 1600,
              backgroundColor: Colors.grey.shade50,
              child: Column(
                children: [
                  _buildDesktopHeader(),
                  if (_companyInfo != null) _buildCompanyInfoCard(),
                  _buildFilterChips(ScreenBreakpoint.desktop),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1200) {
                          return _buildMasterDetailView();
                        } else {
                          return _buildBookingsList();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Panel de Administrador',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<AdminBloc>().add(const LoadAllBookingsEvent());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    if (_companyInfo == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _companyInfo!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _companyInfo!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildInfoItem(
                Icons.location_on,
                _companyInfo!.address,
              ),
              _buildInfoItem(
                Icons.schedule,
                _companyInfo!.scheduleFormatted,
              ),
              _buildInfoItem(
                Icons.phone,
                _companyInfo!.phoneNumber,
              ),
              _buildInfoItem(
                Icons.wb_sunny,
                'Día: S/ ${_companyInfo!.dayPrice.toStringAsFixed(0)}/h',
              ),
              _buildInfoItem(
                Icons.nights_stay,
                'Noche: S/ ${_companyInfo!.nightPrice.toStringAsFixed(0)}/h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ScreenBreakpoint breakpoint) {
    final padding = ResponsiveUtils.getPadding(breakpoint);

    return Container(
      padding: EdgeInsets.all(padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todas', null),
            const SizedBox(width: 8),
            _buildFilterChip('Pendientes', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Confirmadas', 'confirmed'),
            const SizedBox(width: 8),
            _buildFilterChip('Canceladas', 'cancelled'),
            const SizedBox(width: 8),
            _buildFilterChip('Completadas', 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filter) {
    final isSelected = _currentFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = selected ? filter : null;
        });
        context.read<AdminBloc>().add(FilterBookingsByStatusEvent(filter));
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildBookingsList() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar reservas',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminBloc>().add(const LoadAllBookingsEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AdminBookingsLoaded ||
            state is AdminProcessing ||
            state is AdminActionSuccess) {
          final bookings = state is AdminBookingsLoaded
              ? state.filteredBookings
              : state is AdminProcessing
                  ? state.filteredBookings
                  : (state as AdminActionSuccess).filteredBookings;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reservas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    booking.userName ?? 'Usuario sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                      ),
                      Text(
                        '${booking.startTime.hour.toString().padLeft(2, '0')}:00 - ${booking.endTime.hour.toString().padLeft(2, '0')}:00 (${booking.durationHours}h)',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text('S/ ${booking.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: _buildStatusChip(booking.status),
                  onTap: () {
                    // En móvil/tablet navegar a página de detalle
                    final width = MediaQuery.of(context).size.width;
                    if (width < 1200) {
                      // Guardar el bloc ANTES de crear la nueva ruta
                      final adminBloc = context.read<AdminBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (newContext) => BlocProvider.value(
                            value: adminBloc,
                            child: AdminBookingDetailPage(booking: booking),
                          ),
                        ),
                      );
                    } else {
                      // En desktop actualizar selección para Master-Detail
                      setState(() {
                        _selectedBooking = booking;
                      });
                    }
                  },
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMasterDetailView() {
    return Row(
      children: [
        // Lista de reservas (Master)
        SizedBox(
          width: 400,
          child: _buildBookingsList(),
        ),

        const VerticalDivider(thickness: 1, width: 1),

        // Detalle de reserva (Detail)
        Expanded(
          child: _selectedBooking == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selecciona una reserva',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildBookingDetail(_selectedBooking!),
        ),
      ],
    );
  }

  Widget _buildBookingDetail(Booking booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalle de Reserva',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
              _buildInfoRow('Estado', booking.status.name.toUpperCase()),
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
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminBloc>().add(ConfirmBookingEvent(booking.id));
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(booking),
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
              ),
            const SizedBox(height: 16),
          ],

          // Botón de WhatsApp
          if (booking.userPhone != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendWhatsAppMessage(booking),
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
            width: 120,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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

  void _showRejectDialog(Booking booking) {
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

  Future<void> _sendWhatsAppMessage(Booking booking) async {
    // Mostrar dialog para elegir el tipo de mensaje
    final messageType = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text('Enviar mensaje por WhatsApp'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(dialogContext),
                tooltip: 'Cerrar',
              ),
            ],
          ),
          content: const Text('¿Qué tipo de mensaje deseas enviar?'),
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'confirmation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirmación'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'custom'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Personalizado'),
            ),
          ],
        );
      },
    );

    if (messageType == null || !mounted) return;

    bool success = false;

    if (messageType == 'confirmation') {
      // Obtener información de la empresa para incluir el link de Google Maps
      final getCompanyInfo = GetCompanyInfo(context.read<CompanyRepository>());
      final companyResult = await getCompanyInfo();

      String? mapsLink;
      companyResult.fold(
        (failure) => null, // Si falla, enviar sin link
        (companyInfo) => mapsLink = companyInfo.googleMapsLink,
      );

      success = await _whatsappService.sendBookingConfirmation(
        booking,
        mapsLink: mapsLink,
      );
    } else if (messageType == 'rejection') {
      success = await _whatsappService.sendBookingRejection(booking);
    } else if (messageType == 'custom') {
      // Mostrar dialog para mensaje personalizado
      final customMessage = await _showCustomMessageDialog();
      if (customMessage != null && booking.userPhone != null) {
        success = await _whatsappService.sendCustomMessage(
          booking.userPhone!,
          customMessage,
        );
      }
    }

    if (mounted) {
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

  Future<String?> _showCustomMessageDialog() async {
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
