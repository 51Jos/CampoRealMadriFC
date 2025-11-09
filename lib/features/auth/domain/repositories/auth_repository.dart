import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación
/// Esta es la interfaz que la capa de dominio define
/// y la capa de datos implementa
abstract class AuthRepository {
  /// Inicia sesión con email y password
  Future<Either<Failure, UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    required bool acceptTerms,
  });

  /// Cierra sesión
  Future<Either<Failure, void>> signOut();

  /// Obtiene el usuario actual
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Verifica si hay un usuario autenticado
  Future<bool> isAuthenticated();

  /// Envía un correo para restablecer la contraseña
  Future<Either<Failure, void>> resetPassword(String email);
}
