/// Strings globales de la aplicación (antes de implementar i18n)
class AppStrings {
  AppStrings._();

  // Errores comunes
  static const String genericError = 'Ocurrió un error inesperado';
  static const String networkError = 'Error de conexión. Verifica tu internet';
  static const String timeoutError = 'La petición tardó demasiado';
  static const String serverError = 'Error del servidor';

  // Validaciones
  static const String requiredField = 'Este campo es requerido';
  static const String invalidEmail = 'Email inválido';
  static const String invalidPhone = 'Teléfono inválido';

  // Acciones
  static const String accept = 'Aceptar';
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String search = 'Buscar';
}
