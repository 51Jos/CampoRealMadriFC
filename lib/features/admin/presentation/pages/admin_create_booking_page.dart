import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../booking/domain/entities/time_slot.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/presentation/widgets/responsive_constants.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Página para que el admin cree una reserva ingresando datos del cliente
class AdminCreateBookingPage extends StatefulWidget {
  const AdminCreateBookingPage({super.key});

  @override
  State<AdminCreateBookingPage> createState() => _AdminCreateBookingPageState();
}

class _AdminCreateBookingPageState extends State<AdminCreateBookingPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Controladores para datos del cliente
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Flag para saber si ya se ingresaron los datos del cliente
  bool _clientDataEntered = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    super.dispose();
  }

  void _loadTimeSlots() {
    context.read<BookingBloc>().add(LoadAvailableTimeSlotsEvent(_selectedDay));
  }

  String _calculateTotalPrice(TimeSlotsLoaded state) {
    if (state.selectedTimeSlotIds.isEmpty) {
      return '0.00';
    }

    double totalPrice = 0.0;
    for (final slotId in state.selectedTimeSlotIds) {
      final slot = state.timeSlots.firstWhere((s) => s.id == slotId);
      totalPrice += slot.pricePerHour;
    }
    return totalPrice.toStringAsFixed(2);
  }

  List<TimeSlot> _filterAvailableSlots(List<TimeSlot> allSlots, DateTime selectedDate) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return allSlots.where((slot) {
      if (!slot.isAvailable) return false;
      if (isToday && slot.startTime.isBefore(now)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Crear Reserva para Cliente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildContent(ScreenBreakpoint.mobile),
        desktop: _buildContent(ScreenBreakpoint.desktop),
      ),
    );
  }

  Widget _buildContent(ScreenBreakpoint breakpoint) {
    final padding = ResponsiveUtils.getPadding(breakpoint);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: MaxWidthContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paso 1: Información del cliente
            _buildClientInfoSection(breakpoint),

            if (_clientDataEntered) ...[
              const SizedBox(height: 24),
              // Paso 2: Calendario y horarios
              _buildBookingSection(breakpoint),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoSection(ScreenBreakpoint breakpoint) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Datos del Cliente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa los datos del cliente para quien se hará la reserva',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // Campo de nombre
              TextFormField(
                controller: _clientNameController,
                enabled: !_clientDataEntered,
                decoration: InputDecoration(
                  labelText: 'Nombre completo *',
                  hintText: 'Ej: Juan Pérez',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: _clientDataEntered,
                  fillColor: _clientDataEntered ? Colors.grey.shade100 : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.trim().length < 3) {
                    return 'Ingrese un nombre válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de teléfono
              TextFormField(
                controller: _clientPhoneController,
                enabled: !_clientDataEntered,
                decoration: InputDecoration(
                  labelText: 'Teléfono *',
                  hintText: 'Ej: 987654321',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: _clientDataEntered,
                  fillColor: _clientDataEntered ? Colors.grey.shade100 : null,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  if (value.trim().length < 9) {
                    return 'Ingrese un teléfono válido (mínimo 9 dígitos)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de email (opcional)
              TextFormField(
                controller: _clientEmailController,
                enabled: !_clientDataEntered,
                decoration: InputDecoration(
                  labelText: 'Email (opcional)',
                  hintText: 'Ej: cliente@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: _clientDataEntered,
                  fillColor: _clientDataEntered ? Colors.grey.shade100 : null,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Ingrese un email válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón para continuar o editar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_clientDataEntered) {
                      // Permitir editar los datos
                      setState(() {
                        _clientDataEntered = false;
                      });
                    } else {
                      // Validar y continuar
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _clientDataEntered = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Datos del cliente guardados. Ahora selecciona la fecha y horario.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(_clientDataEntered ? Icons.edit : Icons.arrow_forward),
                  label: Text(
                    _clientDataEntered ? 'Editar Datos del Cliente' : 'Continuar con la Reserva',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _clientDataEntered ? Colors.orange : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSection(ScreenBreakpoint breakpoint) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AdminBookingCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Reserva creada exitosamente para ${_clientNameController.text}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(true);
            }
          },
        ),
      ],
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, bookingState) {
          // También escuchar AdminBloc para el estado de carga
          final adminState = context.watch<AdminBloc>().state;

          if (bookingState is BookingLoading || adminState is AdminLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (bookingState is TimeSlotsLoaded) {
            final availableSlots = _filterAvailableSlots(bookingState.timeSlots, _selectedDay);
            final totalPrice = _calculateTotalPrice(bookingState);

            return Column(
            children: [
              // Encabezado del paso 2
              Card(
                elevation: 2,
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selecciona Fecha y Horario',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reserva para: ${_clientNameController.text}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Calendario
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _loadTimeSlots();
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horarios disponibles
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Horarios Disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (availableSlots.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'No hay horarios disponibles para esta fecha',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                            children: availableSlots.map((slot) {
                              final isSelected = bookingState.selectedTimeSlotIds.contains(slot.id);
                              return FilterChip(
                              label: Text(
                                '${slot.startTime.hour}:00 - ${slot.endTime.hour}:00',
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                context.read<BookingBloc>().add(
                                      SelectTimeSlotEvent(slot.id),
                                    );
                              },
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primary : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Resumen y botón crear
              Card(
                elevation: 2,
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a pagar:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'S/ $totalPrice',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: bookingState.selectedTimeSlotIds.isEmpty
                                ? null
                                : () {
                                    // Obtener el userId del admin actual
                                    final authState = context.read<AuthBloc>().state;
                                    String adminUserId = '';
                                    if (authState is AuthAuthenticated) {
                                      adminUserId = authState.user.id;
                                    }

                                    // Obtener el primer slot seleccionado para el startTime
                                    final firstSlotId = bookingState.selectedTimeSlotIds.first;
                                    final firstSlot = bookingState.timeSlots.firstWhere((s) => s.id == firstSlotId);

                                    // Calcular duración en horas
                                    final durationHours = bookingState.selectedTimeSlotIds.length;

                                    // Crear reserva con los datos del cliente usando AdminBloc
                                    context.read<AdminBloc>().add(
                                          CreateAdminBookingEvent(
                                            adminUserId: adminUserId,
                                            date: _selectedDay,
                                            startTime: firstSlot.startTime,
                                            durationHours: durationHours,
                                            clientName: _clientNameController.text.trim(),
                                            clientPhone: _clientPhoneController.text.trim(),
                                            clientEmail: _clientEmailController.text.trim().isEmpty
                                                ? null
                                                : _clientEmailController.text.trim(),
                                          ),
                                        );
                                  },
                          icon: const Icon(Icons.check_circle),
                          label: const Text(
                            'Crear Reserva',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

          return const SizedBox();
        },
      ),
    );
  }
}
