import 'package:equatable/equatable.dart';

/// Clase base para errores de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Error de conexión
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexión a internet',
    super.code,
  });
}

/// Error de caché
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder a datos locales',
    super.code,
  });
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Error de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Error de autenticación',
    super.code,
  });
}

/// Error de autorización
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'No tienes permisos para esta acción',
    super.code,
  });
}

/// Error no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso no encontrado',
    super.code,
  });
}
