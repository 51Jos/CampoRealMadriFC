import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Información General'),
                  _buildTextField(_nameController, 'Nombre de la Empresa', Icons.business),
                  _buildTextField(_descriptionController, 'Descripción', Icons.description, maxLines: 3),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Ubicación'),
                  _buildTextField(_addressController, 'Dirección', Icons.location_on),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_latitudeController, 'Latitud', Icons.map, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_longitudeController, 'Longitud', Icons.map, isNumber: true)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Contacto'),
                  _buildTextField(_phoneController, 'Teléfono', Icons.phone),
                  _buildTextField(_yapeController, 'Número Yape', Icons.payment),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Horario y Precios'),
                  _buildTextField(_scheduleController, 'Horario de Atención', Icons.schedule),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_dayPriceController, 'Precio Día (S/)', Icons.wb_sunny, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_nightPriceController, 'Precio Noche (S/)', Icons.nights_stay, isNumber: true)),
                    ],
                  ),
                  _buildTextField(_nightStartHourController, 'Hora Inicio Tarifa Noche (0-23)', Icons.access_time, isNumber: true),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
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
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        phoneNumber: _phoneController.text.trim(),
        yapeNumber: _yapeController.text.trim(),
        bankAccounts: _currentInfo!.bankAccounts, // Mantener las cuentas existentes
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
