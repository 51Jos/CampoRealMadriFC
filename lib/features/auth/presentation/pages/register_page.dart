import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar los términos y condiciones'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              acceptTerms: _acceptTerms,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Creando cuenta...',
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Card con formulario
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo
                                      Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'src/images/logo.jpeg',
                                            height: 80,
                                            errorBuilder: (context, error, stackTrace) {
                                              // Si el logo no existe, mostrar icono de fútbol
                                              return const Icon(
                                                Icons.sports_soccer,
                                                size: 60,
                                                color: AppColors.primary,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Título
                                      Text(
                                        '¡Únete a nosotros!',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Crea tu cuenta para reservar',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Nombre completo
                                      CustomTextField(
                                        label: 'Nombre Completo',
                                        hint: 'Juan Pérez',
                                        controller: _nameController,
                                        keyboardType: TextInputType.name,
                                        validator: Validators.required,
                                        prefixIcon: const Icon(
                                          Icons.person_outlined,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Número de celular
                                      CustomTextField(
                                        label: 'Número de Celular',
                                        hint: '987654321',
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        validator: Validators.combine([
                                          Validators.required,
                                          (value) {
                                            if (value == null || value.isEmpty) return null;
                                            if (value.length < 9) {
                                              return 'El número debe tener al menos 9 dígitos';
                                            }
                                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                              return 'Solo se permiten números';
                                            }
                                            return null;
                                          },
                                        ]),
                                        prefixIcon: const Icon(
                                          Icons.phone_outlined,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Email
                                      CustomTextField(
                                        label: 'Correo Electrónico',
                                        hint: 'ejemplo@correo.com',
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: Validators.combine([
                                          Validators.required,
                                          Validators.email,
                                        ]),
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Contraseña
                                      CustomTextField(
                                        label: 'Contraseña',
                                        hint: 'Mínimo 6 caracteres',
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        validator: Validators.combine([
                                          Validators.required,
                                          (value) => Validators.minLength(
                                              value, 6),
                                        ]),
                                        prefixIcon: const Icon(
                                          Icons.lock_outlined,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppColors.textSecondary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Confirmar contraseña
                                      CustomTextField(
                                        label: 'Confirmar Contraseña',
                                        hint: 'Repite tu contraseña',
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        validator: Validators.required,
                                        prefixIcon: const Icon(
                                          Icons.lock_outlined,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppColors.textSecondary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Términos y condiciones
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _acceptTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _acceptTerms = value ?? false;
                                              });
                                            },
                                            activeColor: AppColors.primary,
                                          ),
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 13,
                                                ),
                                                children: [
                                                  const TextSpan(text: 'Acepto los '),
                                                  TextSpan(
                                                    text: 'Términos y Condiciones',
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _showTermsDialog(context, 'Términos y Condiciones');
                                                      },
                                                  ),
                                                  const TextSpan(text: ' y la '),
                                                  TextSpan(
                                                    text: 'Política de Privacidad',
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _showTermsDialog(context, 'Política de Privacidad');
                                                      },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Botón de registro
                                      CustomButton(
                                        text: 'Crear Cuenta',
                                        onPressed: _handleSignUp,
                                        width: double.infinity,
                                        icon: Icons.person_add,
                                      ),
                                      const SizedBox(height: 20),

                                      // Ya tengo cuenta
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '¿Ya tienes cuenta?',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => context.pop(),
                                            child: const Text(
                                              'Inicia Sesión',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
        },
      ),
    );
  }

  void _showTermsDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            title == 'Términos y Condiciones'
                ? '''
TÉRMINOS Y CONDICIONES

1. Aceptación de los términos
Al utilizar nuestra aplicación, usted acepta estos términos y condiciones en su totalidad.

2. Uso del servicio
- Debe ser mayor de 18 años para usar este servicio
- Es responsable de mantener la confidencialidad de su cuenta
- No debe usar el servicio para actividades ilegales

3. Reservas
- Las reservas están sujetas a disponibilidad
- Las cancelaciones deben realizarse con 24 horas de anticipación
- Los pagos son procesados de forma segura

4. Política de privacidad
Consulte nuestra Política de Privacidad para más información sobre cómo manejamos sus datos.

5. Modificaciones
Nos reservamos el derecho de modificar estos términos en cualquier momento.
'''
                : '''
POLÍTICA DE PRIVACIDAD

1. Información que recopilamos
- Nombre y datos de contacto
- Información de pago
- Historial de reservas

2. Uso de la información
Utilizamos su información para:
- Procesar sus reservas
- Comunicarnos con usted
- Mejorar nuestros servicios

3. Protección de datos
- Sus datos están protegidos con encriptación
- No compartimos información con terceros sin su consentimiento
- Cumplimos con las leyes de protección de datos

4. Sus derechos
Tiene derecho a:
- Acceder a sus datos
- Solicitar corrección de datos
- Solicitar eliminación de su cuenta

5. Contacto
Para cualquier consulta sobre privacidad, contáctenos a través de la aplicación.
''',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
