import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../config/dependency_injection/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../company/domain/entities/company_info.dart';
import '../../../company/domain/usecases/get_company_info.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../domain/entities/time_slot.dart';
import 'booking_confirmation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CompanyInfo? _companyInfo;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
    _loadTimeSlots();
  }

  Future<void> _loadCompanyInfo() async {
    final getCompanyInfo = sl<GetCompanyInfo>();
    final result = await getCompanyInfo();

    result.fold(
      (failure) {
        // Error loading company info, will use default values from timeSlots
      },
      (companyInfo) {
        if (mounted) {
          setState(() {
            _companyInfo = companyInfo;
          });
        }
      },
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'Reserva tu Campo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BookingCreated) {
            final bloc = context.read<BookingBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationPage(
                  booking: state.booking,
                ),
              ),
            ).then((_) {
              if (mounted) {
                bloc.add(LoadAvailableTimeSlotsEvent(_selectedDay));
              }
            });
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(constraints.maxWidth),
                    _buildCalendar(constraints.maxWidth),
                    if (state is BookingLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (state is TimeSlotsLoaded) ...[
                      _buildTimeSlots(state, constraints.maxWidth),
                      if (state.selectedTimeSlotIds.isNotEmpty)
                        _buildPriceInfo(state, constraints.maxWidth),
                      _buildBookButton(state, constraints.maxWidth),
                    ],
                  ],
                ),
              );
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

  double _getHeaderIconSize(double width) {
    if (width < 360) return 28;
    if (width < 600) return 32;
    return 36;
  }

  double _getTitleFontSize(double width) {
    if (width < 360) return 20;
    if (width < 600) return 24;
    return 26;
  }

  double _getSubtitleFontSize(double width) {
    if (width < 360) return 12;
    if (width < 600) return 14;
    return 15;
  }

  double _getSectionTitleSize(double width) {
    if (width < 360) return 16;
    if (width < 600) return 18;
    return 20;
  }

  int _getGridCrossAxisCount(double width) {
    if (width < 360) return 2; // Móvil muy pequeño: 2 columnas
    if (width < 600) return 3; // Móvil normal: 3 columnas
    if (width < 900) return 4; // Tablet: 4 columnas
    return 5; // Desktop: 5 columnas
  }

  double _getGridAspectRatio(double width) {
    if (width < 360) return 1.0;
    if (width < 600) return 1.2;
    return 1.3;
  }

  Widget _buildHeader(double width) {
    final padding = _getHorizontalPadding(width);
    final iconSize = _getHeaderIconSize(width);
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.sports_soccer,
              color: AppColors.accent,
              size: iconSize,
            ),
          ),
          SizedBox(width: padding * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Real Madrid FC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Campo Sintético - Lima',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: subtitleSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(double width) {
    final padding = _getHorizontalPadding(width);

    return Container(
      margin: EdgeInsets.all(padding),
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
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          context.read<BookingBloc>().add(
                LoadAvailableTimeSlotsEvent(selectedDay),
              );
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
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: _getSectionTitleSize(width) - 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(TimeSlotsLoaded state, double width) {
    final selectedCount = state.selectedTimeSlotIds.length;
    final totalPrice = _calculateTotalPrice(state);
    final padding = _getHorizontalPadding(width);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios seleccionados',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: _getSubtitleFontSize(width) - 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$selectedCount ${selectedCount == 1 ? 'hora' : 'horas'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getSectionTitleSize(width),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total a pagar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: _getSubtitleFontSize(width) - 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'S/ $totalPrice',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: _getTitleFontSize(width),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots(TimeSlotsLoaded state, double width) {
    final availableSlots = _filterAvailableSlots(state.timeSlots, state.selectedDate);
    final padding = _getHorizontalPadding(width);

    if (availableSlots.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay horarios disponibles',
                style: TextStyle(
                  fontSize: _getSectionTitleSize(width) - 2,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: padding),
          Text(
            'Horarios Disponibles',
            style: TextStyle(
              fontSize: _getSectionTitleSize(width),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: padding * 0.5),
          if (_companyInfo != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: padding * 0.75,
                vertical: padding * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Wrap(
                spacing: padding * 0.75,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                  Text(
                    '${_companyInfo!.startHour}:00 - ${_companyInfo!.endHour}:00',
                    style: TextStyle(
                      fontSize: _getSubtitleFontSize(width) - 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(width: padding * 0.5),
                  Icon(Icons.wb_sunny, size: 14, color: Colors.orange.shade700),
                  Text(
                    'Día: S/${_companyInfo!.dayPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: _getSubtitleFontSize(width) - 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Icon(Icons.nightlight_round, size: 14, color: Colors.indigo.shade700),
                  Text(
                    'Noche: S/${_companyInfo!.nightPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: _getSubtitleFontSize(width) - 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: padding * 0.75),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getGridCrossAxisCount(width),
              childAspectRatio: _getGridAspectRatio(width),
              crossAxisSpacing: padding * 0.625,
              mainAxisSpacing: padding * 0.625,
            ),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final slot = availableSlots[index];
              return _buildTimeSlotCard(slot, state, width);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, TimeSlotsLoaded state, double width) {
    final isSelected = state.selectedTimeSlotIds.contains(slot.id);
    final timeFormat = DateFormat('h:mm a', 'es');
    final isNightTime = slot.startTime.hour >= 18;

    return GestureDetector(
      onTap: () {
        context.read<BookingBloc>().add(SelectTimeSlotEvent(slot.id));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNightTime ? Icons.nightlight_round : Icons.wb_sunny,
                  size: 16,
                  color: isSelected ? Colors.white : (isNightTime ? Colors.indigo : Colors.orange),
                ),
                const SizedBox(width: 4),
                Text(
                  'S/ ${slot.pricePerHour.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: _getSubtitleFontSize(width) - 4,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${timeFormat.format(slot.startTime)} -',
              style: TextStyle(
                fontSize: _getSubtitleFontSize(width) - 3,
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            Text(
              timeFormat.format(slot.endTime),
              style: TextStyle(
                fontSize: _getSubtitleFontSize(width) - 3,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(TimeSlotsLoaded state, double width) {
    final canBook = state.selectedTimeSlotIds.isNotEmpty;
    final padding = _getHorizontalPadding(width);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canBook
              ? () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    final firstSlot = state.timeSlots.firstWhere(
                      (slot) => slot.id == state.selectedTimeSlotIds.first,
                    );

                    context.read<BookingBloc>().add(
                          CreateBookingEvent(
                            userId: authState.user.id,
                            date: state.selectedDate,
                            startTime: firstSlot.startTime,
                            durationHours: state.selectedTimeSlotIds.length,
                          ),
                        );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: canBook ? 4 : 0,
          ),
          child: Text(
            canBook ? 'Reservar Ahora' : 'Selecciona horarios',
            style: TextStyle(
              fontSize: _getSectionTitleSize(width) - 2,
              fontWeight: FontWeight.bold,
              color: canBook ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}
