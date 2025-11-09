import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
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
            message: 'Iniciando sesión...',
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getHorizontalPadding(constraints.maxWidth),
                          vertical: _getVerticalPadding(constraints.maxHeight),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _getMaxWidth(constraints.maxWidth),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Card con formulario
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    _getBorderRadius(constraints.maxWidth),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    _getCardPadding(constraints.maxWidth),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Logo
                                        _buildLogo(constraints.maxWidth),
                                        SizedBox(height: _getSpacing(constraints.maxWidth, 24)),

                                        // Título
                                        Text(
                                          'Real Madrid FC',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: _getTitleFontSize(constraints.maxWidth),
                                          ),
                                        ),
                                        SizedBox(height: _getSpacing(constraints.maxWidth, 8)),
                                        Text(
                                          'Reserva tu Cancha',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: _getSubtitleFontSize(constraints.maxWidth),
                                          ),
                                        ),
                                        SizedBox(height: _getSpacing(constraints.maxWidth, 32)),

                                        // Email
                                        CustomTextField(
                                          label: 'Correo Electrónico',
                                          hint: 'ejemplo@correo.com',
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: Validators.combine([
                                            Validators.required,
                                            Validators.email,
                                          ]),
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: _getSpacing(constraints.maxWidth, 20)),

                                        // Password
                                        CustomTextField(
                                          label: 'Contraseña',
                                          hint: '••••••••',
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          validator: Validators.required,
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
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: _getSpacing(constraints.maxWidth, 12)),

                                        // Olvidé mi contraseña
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => _showForgotPasswordDialog(context),
                                            child: Text(
                                              '¿Olvidaste tu contraseña?',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: _getBodyFontSize(constraints.maxWidth),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: _getSpacing(constraints.maxWidth, 24)),

                                        // Botón de inicio de sesión
                                        CustomButton(
                                          text: 'Iniciar Sesión',
                                          onPressed: _handleSignIn,
                                          width: double.infinity,
                                          icon: Icons.login,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: _getSpacing(constraints.maxWidth, 24)),

                              // Footer
                              _buildFooter(context, constraints.maxWidth),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Métodos para calcular dimensiones responsivas
  double _getHorizontalPadding(double width) {
    if (width < 360) return 16; // Móvil muy pequeño
    if (width < 600) return 24; // Móvil normal
    if (width < 900) return 32; // Tablet
    return 48; // Desktop
  }

  double _getVerticalPadding(double height) {
    if (height < 600) return 16;
    if (height < 800) return 24;
    return 32;
  }

  double _getMaxWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth; // Móvil: ancho completo
    if (screenWidth < 900) return 500; // Tablet
    return 450; // Desktop: contenedor fijo
  }

  double _getCardPadding(double width) {
    if (width < 360) return 20;
    if (width < 600) return 24;
    if (width < 900) return 32;
    return 40;
  }

  double _getBorderRadius(double width) {
    if (width < 360) return 16;
    if (width < 600) return 20;
    return 24;
  }

  double _getSpacing(double width, double baseSpacing) {
    if (width < 360) return baseSpacing * 0.75;
    if (width < 600) return baseSpacing;
    return baseSpacing * 1.1;
  }

  double _getTitleFontSize(double width) {
    if (width < 360) return 24;
    if (width < 600) return 28;
    if (width < 900) return 32;
    return 36;
  }

  double _getSubtitleFontSize(double width) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    return 18;
  }

  double _getBodyFontSize(double width) {
    if (width < 360) return 13;
    if (width < 600) return 14;
    return 15;
  }

  double _getLogoSize(double width) {
    if (width < 360) return 70;
    if (width < 600) return 90;
    if (width < 900) return 100;
    return 120;
  }

  Widget _buildLogo(double width) {
    final logoSize = _getLogoSize(width);

    return Container(
      height: logoSize,
      width: logoSize,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(logoSize / 2),
          child: Image.asset(
            'src/images/logo.jpeg',
            height: logoSize * 0.8,
            width: logoSize * 0.8,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.sports_soccer,
                size: logoSize * 0.6,
                color: AppColors.primary,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, double width) {
    final fontSize = _getBodyFontSize(width);

    return Column(
      children: [
        // Texto para crear cuenta
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta? ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: fontSize,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/register'),
              child: Text(
                'Regístrate',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _getSpacing(width, 16)),

        // Mensaje informativo
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: _getSpacing(width, 16),
            vertical: _getSpacing(width, 12),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_soccer,
                color: AppColors.secondary,
                size: _getSpacing(width, 20),
              ),
              SizedBox(width: _getSpacing(width, 8)),
              Flexible(
                child: Text(
                  'Reserva tu cancha fácil y rápido',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: fontSize - 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Correo Electrónico',
                hint: 'ejemplo@correo.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.combine([
                  Validators.required,
                  Validators.email,
                ]),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  Navigator.of(dialogContext).pop();

                  // Mostrar loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Enviar email de recuperación usando Firebase Auth directamente
                  await context.read<AuthBloc>().authRepository.resetPassword(
                    emailController.text.trim(),
                  );

                  // Cerrar loading
                  if (context.mounted) Navigator.of(context).pop();

                  // Mostrar mensaje de éxito
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Se ha enviado un correo para restablecer tu contraseña',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  // Cerrar loading si está abierto
                  if (context.mounted) Navigator.of(context).pop();

                  // Mostrar error
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
                emailController.dispose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
