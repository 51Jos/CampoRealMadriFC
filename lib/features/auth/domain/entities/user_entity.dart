import 'package:equatable/equatable.dart';

/// Entidad de Usuario (capa de dominio - reglas de negocio)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final bool acceptTerms;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.acceptTerms,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, phone, photoUrl, acceptTerms, createdAt];
}
