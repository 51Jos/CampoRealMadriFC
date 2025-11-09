import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Iniciar sesión
/// Encapsula la lógica de negocio para iniciar sesión
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Aquí puedes agregar validaciones de negocio si es necesario
    if (email.isEmpty || password.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Email y contraseña son requeridos'),
      );
    }

    return await repository.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }
}
