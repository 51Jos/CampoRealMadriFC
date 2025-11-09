import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registro de usuario
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
    String? phone,
    required bool acceptTerms,
  }) async {
    // Validaciones de negocio
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return const Left(
        ValidationFailure(
          message: 'Todos los campos son requeridos',
        ),
      );
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure(
          message: 'La contraseña debe tener al menos 6 caracteres',
        ),
      );
    }

    if (!acceptTerms) {
      return const Left(
        ValidationFailure(
          message: 'Debes aceptar los términos y condiciones',
        ),
      );
    }

    return await repository.signUpWithEmailPassword(
      email: email,
      password: password,
      name: name,
      phone: phone,
      acceptTerms: acceptTerms,
    );
  }
}
