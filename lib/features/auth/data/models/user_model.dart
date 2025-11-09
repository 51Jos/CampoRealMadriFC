import '../../domain/entities/user_entity.dart';

/// Modelo de Usuario (capa de datos)
/// Extiende la entidad y agrega métodos de serialización
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.photoUrl,
    required super.acceptTerms,
    required super.createdAt,
  });

  /// Crea un UserModel desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      acceptTerms: json['acceptTerms'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'acceptTerms': acceptTerms,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea un UserModel desde una entidad
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      acceptTerms: entity.acceptTerms,
      createdAt: entity.createdAt,
    );
  }
}
