import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Fuente de datos remota para autenticación
/// Maneja la comunicación con Firebase Auth
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    required bool acceptTerms,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    String? photoUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }

      // Intentar obtener datos de Firestore primero
      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          return UserModel(
            id: user.uid,
            email: user.email!,
            name: data['name'] ?? user.displayName ?? 'Usuario',
            phone: data['phone'] as String?,
            photoUrl: data['photoUrl'] ?? user.photoURL,
            acceptTerms: data['acceptTerms'] as bool? ?? false,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
                      user.metadata.creationTime ??
                      DateTime.now(),
          );
        }
      } catch (e) {
        // Si falla, usar datos de Firebase Auth
      }

      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? 'Usuario',
        phone: null,
        photoUrl: user.photoURL,
        acceptTerms: false,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    required bool acceptTerms,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Error al crear usuario');
      }

      // Actualizar el nombre del usuario en Firebase Auth
      await user.updateDisplayName(name);

      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        name: name,
        phone: phone,
        photoUrl: user.photoURL,
        acceptTerms: acceptTerms,
        createdAt: DateTime.now(),
      );

      // Guardar información del usuario en Firestore
      await firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email!,
        'name': name,
        'phone': phone,
        'photoUrl': user.photoURL,
        'acceptTerms': acceptTerms,
        'createdAt': Timestamp.fromDate(userModel.createdAt),
      });

      return userModel;
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      // Intentar obtener datos de Firestore primero
      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          return UserModel(
            id: user.uid,
            email: user.email!,
            name: data['name'] ?? user.displayName ?? 'Usuario',
            phone: data['phone'] as String?,
            photoUrl: data['photoUrl'] ?? user.photoURL,
            acceptTerms: data['acceptTerms'] as bool? ?? false,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
                      user.metadata.creationTime ??
                      DateTime.now(),
          );
        }
      } catch (e) {
        // Si falla, usar datos de Firebase Auth
      }

      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? 'Usuario',
        phone: null,
        photoUrl: user.photoURL,
        acceptTerms: false,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Error al enviar correo de recuperación: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Actualizar en Firebase Auth
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Actualizar en Firestore
      await firestore.collection('users').doc(user.uid).update({
        'name': name,
        'phone': phone,
        'photoUrl': photoUrl ?? user.photoURL,
      });

      // Obtener el usuario actualizado
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data()!;

      return UserModel(
        id: user.uid,
        email: user.email!,
        name: data['name'] ?? name,
        phone: data['phone'] as String?,
        photoUrl: data['photoUrl'] ?? user.photoURL,
        acceptTerms: data['acceptTerms'] as bool? ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Usuario no autenticado');
      }

      // Re-autenticar al usuario con su contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambiar la contraseña
      await user.updatePassword(newPassword);
    } catch (e) {
      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        throw Exception('La contraseña actual es incorrecta');
      }
      throw Exception('Error al cambiar contraseña: $e');
    }
  }
}
