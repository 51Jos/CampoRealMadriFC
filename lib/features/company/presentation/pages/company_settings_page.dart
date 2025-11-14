import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/company_info.dart';
import '../bloc/company_bloc.dart';
import '../bloc/company_event.dart';
import '../bloc/company_state.dart';

/// Página para configurar la información de la empresa (solo admin)
class CompanySettingsPage extends StatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  State<CompanySettingsPage> createState() => _CompanySettingsPageState();
}

class _CompanySettingsPageState extends State<CompanySettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _yapeController;
  late TextEditingController _dayPriceController;
  late TextEditingController _nightPriceController;
  late TextEditingController _nightStartHourController;

  CompanyInfo? _currentInfo;
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-12.0464, -77.0428);
  Set<Marker> _markers = {};

  // Horarios
  int _startHour = 8;
  int _endHour = 22;

  @override
  void initState() {
    super.initState();
    _initControllers();
    context.read<CompanyBloc>().add(const LoadCompanyInfoEvent());
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _yapeController = TextEditingController();
    _dayPriceController = TextEditingController();
    _nightPriceController = TextEditingController();
    _nightStartHourController = TextEditingController();
  }

  void _loadInfoToControllers(CompanyInfo info) {
    _currentInfo = info;
    _nameController.text = info.name;
    _descriptionController.text = info.description;
    _addressController.text = info.address;
    _phoneController.text = info.phoneNumber;
    _yapeController.text = info.yapeNumber;
    _dayPriceController.text = info.dayPrice.toString();
    _nightPriceController.text = info.nightPrice.toString();
    _nightStartHourController.text = info.nightStartHour.toString();
    _startHour = info.startHour;
    _endHour = info.endHour;

    _selectedLocation = LatLng(info.latitude, info.longitude);
    _updateMarker(_selectedLocation);
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('company_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _updateMarker(newPosition);
          },
        ),
      };
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _yapeController.dispose();
    _dayPriceController.dispose();
    _nightPriceController.dispose();
    _nightStartHourController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail lateral (igual que el dashboard)
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
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Configuración'),
              ),
            ],
            selectedIndex: 1, // Configuración está seleccionada
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/admin/dashboard');
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
            child: BlocConsumer<CompanyBloc, CompanyState>(
              listener: (context, state) {
                if (state is CompanyLoaded) {
                  _loadInfoToControllers(state.companyInfo);
                } else if (state is CompanyUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Información actualizada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is CompanyError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is CompanyLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                return Container(
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _buildContent(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            'Configuración de Empresa',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Información General'),
                _buildTextField(_nameController, 'Nombre de la Empresa', Icons.business, maxLines: 1),
                _buildTextField(_descriptionController, 'Descripción', Icons.description, maxLines: 3),

                const SizedBox(height: 32),
                _buildSectionTitle('Ubicación'),
                _buildTextField(_addressController, 'Dirección', Icons.location_on, maxLines: 1),
                const SizedBox(height: 16),
                _buildMapSection(),

                const SizedBox(height: 32),
                _buildSectionTitle('Contacto'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_phoneController, 'Teléfono', Icons.phone, maxLines: 1)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_yapeController, 'Número Yape', Icons.payment, maxLines: 1)),
                  ],
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Horario de Atención'),
                Row(
                  children: [
                    Expanded(
                      child: _buildHourSelector(
                        'Hora de Inicio',
                        _startHour,
                        (value) => setState(() => _startHour = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildHourSelector(
                        'Hora de Cierre',
                        _endHour,
                        (value) => setState(() => _endHour = value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Precios'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_dayPriceController, 'Precio Día (S/)', Icons.wb_sunny, isNumber: true, maxLines: 1)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_nightPriceController, 'Precio Noche (S/)', Icons.nights_stay, isNumber: true, maxLines: 1)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_nightStartHourController, 'Hora Inicio Tarifa Noche (0-23)', Icons.access_time, isNumber: true, maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 15,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (position) {
          _updateMarker(position);
        },
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }

  Widget _buildHourSelector(String label, int currentHour, Function(int) onChanged) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<int>(
          context: context,
          builder: (context) => _HourPickerDialog(
            initialHour: currentHour,
            title: label,
          ),
        );
        if (selected != null) {
          onChanged(selected);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        child: Text(_formatHour(currentHour)),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate() && _currentInfo != null) {
      final updatedInfo = CompanyInfo(
        id: _currentInfo!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        phoneNumber: _phoneController.text.trim(),
        yapeNumber: _yapeController.text.trim(),
        bankAccounts: _currentInfo!.bankAccounts,
        startHour: _startHour,
        endHour: _endHour,
        dayPrice: double.tryParse(_dayPriceController.text) ?? 0.0,
        nightPrice: double.tryParse(_nightPriceController.text) ?? 0.0,
        nightStartHour: int.tryParse(_nightStartHourController.text) ?? 18,
        updatedAt: DateTime.now(),
      );

      context.read<CompanyBloc>().add(UpdateCompanyInfoEvent(updatedInfo));
    }
  }
}

/// Dialog para seleccionar hora
class _HourPickerDialog extends StatelessWidget {
  final int initialHour;
  final String title;

  const _HourPickerDialog({
    required this.initialHour,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          itemCount: 24,
          itemBuilder: (context, index) {
            final hour = index;
            final isSelected = hour == initialHour;
            return ListTile(
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
              title: Text(
                _formatHour(hour),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
              onTap: () => Navigator.pop(context, hour),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}
