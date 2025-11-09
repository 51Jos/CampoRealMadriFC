import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para actualizar el perfil del usuario
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    String? phone,
    String? photoUrl,
  }) async {
    return await repository.updateProfile(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );
  }
}
