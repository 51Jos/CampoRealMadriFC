import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _phoneController;
  late TextEditingController _yapeController;
  late TextEditingController _scheduleController;
  late TextEditingController _dayPriceController;
  late TextEditingController _nightPriceController;
  late TextEditingController _nightStartHourController;

  CompanyInfo? _currentInfo;

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
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _phoneController = TextEditingController();
    _yapeController = TextEditingController();
    _scheduleController = TextEditingController();
    _dayPriceController = TextEditingController();
    _nightPriceController = TextEditingController();
    _nightStartHourController = TextEditingController();
  }

  void _loadInfoToControllers(CompanyInfo info) {
    _currentInfo = info;
    _nameController.text = info.name;
    _descriptionController.text = info.description;
    _addressController.text = info.address;
    _latitudeController.text = info.latitude.toString();
    _longitudeController.text = info.longitude.toString();
    _phoneController.text = info.phoneNumber;
    _yapeController.text = info.yapeNumber;
    _scheduleController.text = info.schedule;
    _dayPriceController.text = info.dayPrice.toString();
    _nightPriceController.text = info.nightPrice.toString();
    _nightStartHourController.text = info.nightStartHour.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();
    _yapeController.dispose();
    _scheduleController.dispose();
    _dayPriceController.dispose();
    _nightPriceController.dispose();
    _nightStartHourController.dispose();
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
                _buildResponsiveRow(
                  breakpoint,
                  [
                    Expanded(child: _buildTextField(_latitudeController, 'Latitud', Icons.map, breakpoint, isNumber: true)),
                    SizedBox(width: ResponsiveUtils.getSpacing(breakpoint)),
                    Expanded(child: _buildTextField(_longitudeController, 'Longitud', Icons.map, breakpoint, isNumber: true)),
                  ],
                ),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 2),
                _buildSectionTitle('Contacto', breakpoint),
                _buildTextField(_phoneController, 'Teléfono', Icons.phone, breakpoint),
                _buildTextField(_yapeController, 'Número Yape', Icons.payment, breakpoint),

                SizedBox(height: ResponsiveUtils.getSpacing(breakpoint) * 2),
                _buildSectionTitle('Horario y Precios', breakpoint),
                _buildTextField(_scheduleController, 'Horario de Atención', Icons.schedule, breakpoint),
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
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        phoneNumber: _phoneController.text.trim(),
        yapeNumber: _yapeController.text.trim(),
        bankAccounts: _currentInfo!.bankAccounts,
        schedule: _scheduleController.text.trim(),
        dayPrice: double.tryParse(_dayPriceController.text) ?? 0.0,
        nightPrice: double.tryParse(_nightPriceController.text) ?? 0.0,
        nightStartHour: int.tryParse(_nightStartHourController.text) ?? 18,
        updatedAt: DateTime.now(),
      );

      context.read<CompanyBloc>().add(UpdateCompanyInfoEvent(updatedInfo));
    }
  }
}
