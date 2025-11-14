import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/widgets/responsive_constants.dart';
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
  LatLng _selectedLocation = const LatLng(-12.0464, -77.0428); // Default Lima
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

    // Actualizar ubicación en el mapa
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
      appBar: AppBar(
        title: const Text('Configuración de Empresa', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<CompanyBloc, CompanyState>(
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
            Navigator.pop(context);
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final breakpoint = ResponsiveUtils.getBreakpoint(constraints.maxWidth);
              return _buildResponsiveContent(breakpoint);
            },
          );
        },
      ),
    );
  }

  Widget _buildResponsiveContent(ScreenBreakpoint breakpoint) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUtils.getPadding(breakpoint)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Información General', breakpoint),
                _buildTextField(_nameController, 'Nombre de la Empresa', Icons.business, breakpoint),
                _buildTextField(_descriptionController, 'Descripción', Icons.description, breakpoint, maxLines: 3),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 2),
                _buildSectionTitle('Ubicación', breakpoint),
                _buildTextField(_addressController, 'Dirección', Icons.location_on, breakpoint),
                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint)),
                _buildMapSection(breakpoint),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 2),
                _buildSectionTitle('Contacto', breakpoint),
                _buildTextField(_phoneController, 'Teléfono', Icons.phone, breakpoint),
                _buildTextField(_yapeController, 'Número Yape', Icons.payment, breakpoint),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 2),
                _buildSectionTitle('Horario de Atención', breakpoint),
                _buildHourSelectors(breakpoint),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 2),
                _buildSectionTitle('Precios', breakpoint),
                _buildResponsiveRow(
                  breakpoint,
                  [
                    Expanded(child: _buildTextField(_dayPriceController, 'Precio Día (S/)', Icons.wb_sunny, breakpoint, isNumber: true)),
                    SizedBox(width: ResponsiveUtils.getSpacing(breakpoint)),
                    Expanded(child: _buildTextField(_nightPriceController, 'Precio Noche (S/)', Icons.nights_stay, breakpoint, isNumber: true)),
                  ],
                ),
                _buildTextField(_nightStartHourController, 'Hora Inicio Tarifa Noche (0-23)', Icons.access_time, breakpoint, isNumber: true),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 3),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(breakpoint),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodySize(breakpoint),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(ScreenBreakpoint breakpoint) {
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

  Widget _buildHourSelectors(ScreenBreakpoint breakpoint) {
    return _buildResponsiveRow(
      breakpoint,
      [
        Expanded(
          child: _buildHourSelector(
            'Hora de Inicio',
            _startHour,
            (value) => setState(() => _startHour = value),
            breakpoint,
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(breakpoint)),
        Expanded(
          child: _buildHourSelector(
            'Hora de Cierre',
            _endHour,
            (value) => setState(() => _endHour = value),
            breakpoint,
          ),
        ),
      ],
    );
  }

  Widget _buildHourSelector(String label, int currentHour, Function(int) onChanged, ScreenBreakpoint breakpoint) {
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
          labelStyle: TextStyle(fontSize: ResponsiveUtils.getBodySize(breakpoint)),
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
        child: Text(
          _formatHour(currentHour),
          style: TextStyle(fontSize: ResponsiveUtils.getBodySize(breakpoint)),
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  Widget _buildResponsiveRow(ScreenBreakpoint breakpoint, List<Widget> children) {
    // En móvil muestra columna, en tablet+ muestra fila
    if (breakpoint == ScreenBreakpoint.mobile) {
      return Column(
        children: children.map((child) {
          if (child is SizedBox) return child;
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(breakpoint)),
            child: child,
          );
        }).toList(),
      );
    }
    return Row(children: children);
  }

  Widget _buildSectionTitle(String title, ScreenBreakpoint breakpoint) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(breakpoint)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getSubtitleSize(breakpoint),
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    ScreenBreakpoint breakpoint, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(breakpoint)),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(fontSize: ResponsiveUtils.getBodySize(breakpoint)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: ResponsiveUtils.getBodySize(breakpoint)),
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
