import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditMode = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _isEditMode = false);
            context.read<AuthBloc>().add(CheckAuthStatus());
          } else if (state is PasswordChangeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated || state is ProfileUpdateSuccess) {
            final user = state is AuthAuthenticated
                ? state.user
                : (state as ProfileUpdateSuccess).user;

            _nameController.text = user.name;
            _phoneController.text = user.phone ?? '';
            _emailController.text = user.email;

            return LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(context, user.name, constraints.maxWidth),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildProfileHeader(
                            user.name,
                            user.email,
                            user.photoUrl,
                            constraints.maxWidth,
                          ),
                          SizedBox(height: _getSpacing(constraints.maxWidth, 24)),
                          _buildProfileForm(constraints.maxWidth),
                          SizedBox(height: _getSpacing(constraints.maxWidth, 16)),
                          _buildMenuSection(context, constraints.maxWidth),
                          SizedBox(height: _getSpacing(constraints.maxWidth, 24)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
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

  double _getAppBarHeight(double width) {
    if (width < 360) return 100;
    if (width < 600) return 120;
    return 140;
  }

  double _getAvatarSize(double width) {
    if (width < 360) return 100;
    if (width < 600) return 120;
    if (width < 900) return 140;
    return 150;
  }

  double _getTitleFontSize(double width) {
    if (width < 360) return 20;
    if (width < 600) return 24;
    return 26;
  }

  double _getSubtitleFontSize(double width) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    return 17;
  }

  double _getSectionTitleSize(double width) {
    if (width < 360) return 16;
    if (width < 600) return 18;
    return 20;
  }

  double _getBodyFontSize(double width) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    return 16;
  }

  double _getButtonFontSize(double width) {
    if (width < 360) return 13;
    if (width < 600) return 14;
    return 15;
  }

  double _getSpacing(double width, double baseSpacing) {
    if (width < 360) return baseSpacing * 0.75;
    if (width < 600) return baseSpacing;
    return baseSpacing * 1.1;
  }

  Widget _buildAppBar(BuildContext context, String userName, double width) {
    final appBarHeight = _getAppBarHeight(width);

    return SliverAppBar(
      expandedHeight: appBarHeight,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _isEditMode ? 'Editar Perfil' : 'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: _getBodyFontSize(width),
          ),
        ),
        background: Container(
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
        ),
      ),
      actions: [
        if (_isEditMode)
          TextButton(
            onPressed: () {
              setState(() => _isEditMode = false);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getButtonFontSize(width),
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() => _isEditMode = true);
            },
          ),
      ],
    );
  }

  Widget _buildProfileHeader(
    String name,
    String email,
    String? photoUrl,
    double width,
  ) {
    final padding = _getHorizontalPadding(width);
    final avatarSize = _getAvatarSize(width);
    final titleSize = _getTitleFontSize(width);
    final subtitleSize = _getSubtitleFontSize(width);

    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(avatarSize / 2),
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: avatarSize * 0.5,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: avatarSize * 0.5,
                        color: Colors.white,
                      ),
              ),
              if (_isEditMode)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(padding * 0.5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: padding,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: padding),
          if (!_isEditMode) ...[
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: padding * 0.25),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileForm(double width) {
    final padding = _getHorizontalPadding(width);
    final titleSize = _getSectionTitleSize(width);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      padding: EdgeInsets.all(padding * 1.25),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Personal',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: padding * 1.25),
            CustomTextField(
              label: 'Nombre Completo',
              controller: _nameController,
              enabled: _isEditMode,
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            SizedBox(height: padding),
            CustomTextField(
              label: 'Correo Electrónico',
              controller: _emailController,
              enabled: false,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: padding),
            CustomTextField(
              label: 'Teléfono',
              controller: _phoneController,
              enabled: _isEditMode,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
            ),
            if (_isEditMode) ...[
              SizedBox(height: padding * 1.5),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return CustomButton(
                      text: isLoading ? 'Guardando...' : 'Guardar Cambios',
                      onPressed: isLoading ? null : _saveProfile,
                      backgroundColor: AppColors.primary,
                      icon: Icons.save,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, double width) {
    final padding = _getHorizontalPadding(width);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
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
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Cambiar Contraseña',
            subtitle: 'Actualiza tu contraseña',
            onTap: () => _showChangePasswordDialog(context, width),
            iconColor: AppColors.primary,
            width: width,
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Versión 1.0.0',
            onTap: () {},
            iconColor: Colors.blue,
            width: width,
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            subtitle: 'Obtén ayuda',
            onTap: () {},
            iconColor: Colors.orange,
            width: width,
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de tu cuenta',
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
            width: width,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    required double width,
  }) {
    final padding = _getHorizontalPadding(width);
    final titleSize = _getBodyFontSize(width);
    final subtitleSize = _getButtonFontSize(width);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: padding * 1.25,
        vertical: padding * 0.5,
      ),
      leading: Container(
        padding: EdgeInsets.all(padding * 0.5),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.grey.shade700,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: titleSize,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: subtitleSize,
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            UpdateProfileRequested(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            ),
          );
    }
  }

  void _showChangePasswordDialog(BuildContext context, double width) {
    final authBloc = context.read<AuthBloc>();
    final padding = _getHorizontalPadding(width);
    final titleSize = _getSectionTitleSize(width);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: authBloc,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                SizedBox(height: padding * 1.25),
                CustomTextField(
                  label: 'Contraseña Actual',
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: padding),
                CustomTextField(
                  label: 'Nueva Contraseña',
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: padding),
                CustomTextField(
                  label: 'Confirmar Nueva Contraseña',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: padding * 1.5),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (blocContext, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: isLoading ? 'Cambiando...' : 'Cambiar Contraseña',
                        onPressed: isLoading ? null : () => _changePassword(blocContext),
                        backgroundColor: AppColors.primary,
                        icon: Icons.check,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          ChangePasswordRequested(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          ),
        );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(SignOutRequested());
              context.go(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
