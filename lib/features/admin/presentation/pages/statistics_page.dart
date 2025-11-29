import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/statistics.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedNavIndex = 1; // Estadísticas es el índice 1

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatisticsBloc>().add(const RefreshStatisticsEvent());
            },
          ),
        ],
      ),
      body: _buildStatisticsContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/admin/dashboard');
          } else if (index == 1) {
            // Ya estamos en estadísticas
            setState(() {
              _selectedNavIndex = 1;
            });
          } else if (index == 2) {
            context.push('/admin/company-settings');
          } else if (index == 3) {
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
            selectedIndex: 1,
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/admin/dashboard');
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
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // AppBar personalizado para desktop
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            context.read<StatisticsBloc>().add(const RefreshStatisticsEvent());
                          },
                          tooltip: 'Actualizar',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _buildStatisticsContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StatisticsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar estadísticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StatisticsBloc>().add(const LoadStatisticsEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is StatisticsLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<StatisticsBloc>().add(const RefreshStatisticsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingStatsSection(context, state.statistics.bookingStats),
                  const SizedBox(height: 24),
                  _buildIncomeStatsSection(context, state.statistics.incomeStats),
                  const SizedBox(height: 24),
                  _buildPeakHoursSection(context, state.statistics.peakHoursStats),
                  const SizedBox(height: 24),
                  _buildWeeklyChartSection(context, state.statistics.bookingStats),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildBookingStatsSection(BuildContext context, BookingStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.today,
                title: 'Hoy',
                value: '${stats.todayBookings}',
                subtitle: '${stats.todayHours.toStringAsFixed(1)} hrs',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_view_week,
                title: 'Semana',
                value: '${stats.weekBookings}',
                subtitle: '${stats.weekHours.toStringAsFixed(1)} hrs',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.calendar_month,
          title: 'Este Mes',
          value: '${stats.monthBookings}',
          subtitle: '${stats.monthHours.toStringAsFixed(1)} hrs',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildIncomeStatsSection(BuildContext context, IncomeStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingresos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.today,
                title: 'Hoy',
                value: 'S/ ${stats.todayIncome.toStringAsFixed(2)}',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_view_week,
                title: 'Semana',
                value: 'S/ ${stats.weekIncome.toStringAsFixed(2)}',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_month,
                title: 'Mes',
                value: 'S/ ${stats.monthIncome.toStringAsFixed(2)}',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.monetization_on,
                title: 'Total',
                value: 'S/ ${stats.totalIncome.toStringAsFixed(2)}',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodBreakdown(context, stats.paymentBreakdown),
      ],
    );
  }

  Widget _buildPaymentMethodBreakdown(
    BuildContext context,
    PaymentMethodBreakdown breakdown,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por Método de Pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodRow('Efectivo', breakdown.efectivo, Colors.green),
            const SizedBox(height: 8),
            _buildPaymentMethodRow('Yape', breakdown.yape, Colors.purple),
            const SizedBox(height: 8),
            _buildPaymentMethodRow('Plin', breakdown.plin, Colors.blue),
            const SizedBox(height: 8),
            _buildPaymentMethodRow('Transferencia', breakdown.transferencia, Colors.orange),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'S/ ${breakdown.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(String method, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            method,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          'S/ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPeakHoursSection(BuildContext context, PeakHoursStats stats) {
    final topHours = stats.topHours;

    if (topHours.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horas Más Reservadas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: topHours.map((hourlyBooking) {
                final maxCount = topHours.first.count;
                final percentage = hourlyBooking.count / maxCount;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hourlyBooking.hourLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${hourlyBooking.count} reservas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChartSection(BuildContext context, BookingStats stats) {
    if (stats.dailyBookings.isEmpty) {
      return const SizedBox();
    }

    final maxHours = stats.dailyBookings
        .map((e) => e.hours)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad de la Semana',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stats.dailyBookings.map((daily) {
                      final heightPercentage = maxHours > 0 ? daily.hours / maxHours : 0;
                      final barHeight = 150 * heightPercentage;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${daily.hours.toStringAsFixed(0)}h',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                height: barHeight.clamp(4.0, 150.0).toDouble(),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('E', 'es').format(daily.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
