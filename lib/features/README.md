# Features

Esta carpeta contiene todas las **funcionalidades** de la aplicación, organizadas por módulos independientes siguiendo **Clean Architecture**.

## 🏗️ Estructura de un Feature

Cada feature tiene tres capas principales:

```
feature_name/
├── domain/          # Reglas de negocio (puro Dart)
│   ├── entities/    # Objetos de negocio
│   ├── repositories/# Contratos (interfaces)
│   └── usecases/    # Casos de uso
├── data/            # Implementación de datos
│   ├── models/      # Modelos con JSON
│   ├── datasources/ # APIs, DB local
│   └── repositories/# Implementación de contratos
├── presentation/    # UI y manejo de estado
│   ├── bloc/        # BLoC (eventos, estados)
│   ├── pages/       # Pantallas
│   └── widgets/     # Widgets del feature
└── feature_name.dart # Barrel file
```

## 📋 Ejemplo: Feature Auth

### Domain (Dominio)
Define **QUÉ** hace la aplicación, no **CÓMO**.

**entities/user_entity.dart**
```dart
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  // Objeto puro, sin dependencias externas
}
```

**repositories/auth_repository.dart**
```dart
// Contrato (interface)
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({...});
}
```

**usecases/sign_in_usecase.dart**
```dart
// Lógica de negocio
class SignInUseCase {
  final AuthRepository repository;

  Future<Either<Failure, UserEntity>> call({...}) {
    // Validaciones de negocio
    return repository.signIn(...);
  }
}
```

### Data (Datos)
Implementa **CÓMO** se obtienen/guardan los datos.

**models/user_model.dart**
```dart
// Extiende la entidad y agrega serialización
class UserModel extends UserEntity {
  factory UserModel.fromJson(Map<String, dynamic> json) {...}
  Map<String, dynamic> toJson() {...}
}
```

**datasources/auth_remote_datasource.dart**
```dart
// Comunicación con Firebase/API
class AuthRemoteDataSourceImpl {
  Future<UserModel> signIn({...}) {
    // Llamada a Firebase Auth
  }
}
```

**repositories/auth_repository_impl.dart**
```dart
// Implementa el contrato del dominio
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  @override
  Future<Either<Failure, UserEntity>> signIn({...}) {
    try {
      final user = await dataSource.signIn(...);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(...));
    }
  }
}
```

### Presentation (Presentación)
Maneja la **UI y el estado**.

**bloc/auth_bloc.dart**
```dart
// Events
class SignInRequested extends AuthEvent {...}

// States
class AuthAuthenticated extends AuthState {...}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;

  on<SignInRequested>((event, emit) async {
    final result = await signInUseCase(...);
    result.fold(
      (failure) => emit(AuthError(...)),
      (user) => emit(AuthAuthenticated(user)),
    );
  });
}
```

**pages/login_page.dart**
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          // Mostrar error
        }
      },
      builder: (context, state) {
        // UI
      },
    );
  }
}
```

## 🔄 Flujo de Datos

```
Usuario toca botón
    ↓
Widget dispara evento → BLoC
    ↓
BLoC llama → UseCase (Domain)
    ↓
UseCase usa → Repository Interface (Domain)
    ↓
Repository Implementation (Data) consulta → DataSource
    ↓
DataSource llama → API/Firebase
    ↓
Respuesta regresa por las capas
    ↓
BLoC emite nuevo estado
    ↓
UI se actualiza automáticamente
```

## ➕ Cómo Agregar un Nuevo Feature

1. **Crear estructura de carpetas**
```bash
mkdir -p features/mi_feature/{domain/{entities,repositories,usecases},data/{models,datasources,repositories},presentation/{bloc,pages,widgets}}
```

2. **Empezar por Domain** (independiente):
   - Definir entidades
   - Definir interfaces de repositorios
   - Crear casos de uso

3. **Implementar Data**:
   - Crear modelos (extends Entity)
   - Crear datasources (API calls)
   - Implementar repositorios

4. **Crear Presentation**:
   - Definir eventos y estados
   - Crear BLoC
   - Crear páginas y widgets

5. **Crear barrel file** `mi_feature.dart`:
```dart
// Domain
export 'domain/entities/...';
export 'domain/repositories/...';
export 'domain/usecases/...';

// Data
export 'data/models/...';
export 'data/datasources/...';
export 'data/repositories/...';

// Presentation
export 'presentation/bloc/...';
export 'presentation/pages/...';
```

## ✅ Ventajas de esta Arquitectura

- ✨ **Testeable**: Cada capa se testea independientemente
- 🔧 **Mantenible**: Cambios localizados, fácil de encontrar código
- 🚀 **Escalable**: Agregar features sin afectar otros
- 🔄 **Reutilizable**: Casos de uso compartidos entre features
- 📦 **Modular**: Features independientes, pueden removerse fácilmente

## 🎯 Reglas de Dependencia

```
Presentation → Domain ← Data
     ↓           ↑         ↓
   Widgets   Entities   Models
     ↓           ↑         ↓
    BLoC    UseCases  DataSources
               ↑
          Repositories (interface)
```

- Domain no depende de nadie (solo Dart puro)
- Data implementa interfaces de Domain
- Presentation usa casos de uso de Domain
- Las dependencias van hacia el centro (Domain)

## 📚 Ejemplos de Features Comunes

- **auth/** - Autenticación y autorización
- **home/** - Pantalla principal
- **reservations/** - Reservas de canchas
- **payments/** - Pagos y facturación
- **profile/** - Perfil de usuario
- **notifications/** - Notificaciones push
