# Arquitectura del Proyecto - Sintético Lima

## 📁 Estructura de Carpetas

Este proyecto sigue una **arquitectura limpia (Clean Architecture)** combinada con una **organización por features** para mantener el código escalable, mantenible y reutilizable.

```
lib/
├── core/                      # Código compartido en toda la app
│   ├── constants/            # Constantes globales
│   │   ├── app_constants.dart
│   │   └── app_strings.dart
│   ├── theme/                # Temas y estilos
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── utils/                # Utilidades reutilizables
│   │   ├── validators.dart
│   │   └── formatters.dart
│   ├── errors/               # Manejo de errores
│   │   └── failures.dart
│   ├── network/              # Cliente HTTP
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── extensions/           # Extensiones de Dart/Flutter
│   │   ├── string_extensions.dart
│   │   └── context_extensions.dart
│   └── core.dart            # Barrel file
│
├── shared/                   # Componentes compartidos entre features
│   ├── widgets/             # Widgets reutilizables
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_overlay.dart
│   │   └── empty_state.dart
│   ├── services/            # Servicios compartidos
│   │   └── storage_service.dart
│   ├── models/              # Modelos compartidos
│   └── shared.dart          # Barrel file
│
├── config/                   # Configuraciones globales
│   ├── routes/              # Configuración de rutas
│   │   └── app_router.dart
│   └── environment/         # Variables de entorno
│       └── env_config.dart
│
├── features/                 # Features de la aplicación
│   └── auth/                # Feature de autenticación (EJEMPLO)
│       ├── data/            # Capa de datos
│       │   ├── models/      # Modelos de datos
│       │   ├── datasources/ # Fuentes de datos (API, local)
│       │   └── repositories/# Implementación de repositorios
│       ├── domain/          # Capa de dominio (reglas de negocio)
│       │   ├── entities/    # Entidades de negocio
│       │   ├── repositories/# Contratos de repositorios
│       │   └── usecases/    # Casos de uso
│       ├── presentation/    # Capa de presentación (UI)
│       │   ├── bloc/        # Bloc para manejo de estado
│       │   ├── pages/       # Páginas/Pantallas
│       │   └── widgets/     # Widgets específicos del feature
│       └── auth.dart        # Barrel file del feature
│
├── main.dart                 # Punto de entrada
└── firebase_options.dart     # Configuración de Firebase
```

## 🏗️ Capas de la Arquitectura

### 1. **Core** (Núcleo Global)
Contiene todo el código que se reutiliza en toda la aplicación y NO depende de ningún feature específico.

- **constants/**: Valores constantes (URLs, timeouts, etc.)
- **theme/**: Temas visuales, colores, estilos
- **utils/**: Validadores, formateadores, helpers
- **errors/**: Clases de error personalizadas
- **network/**: Cliente HTTP centralizado
- **extensions/**: Extensiones útiles para tipos nativos

**Regla**: El core NO debe importar nada de `features/` o `shared/`

### 2. **Shared** (Compartido)
Componentes que se comparten entre múltiples features pero NO son parte del core.

- **widgets/**: Componentes UI reutilizables
- **services/**: Servicios compartidos (storage, cache, etc.)
- **models/**: Modelos de datos compartidos

**Regla**: Shared puede usar `core/` pero NO debe importar `features/`

### 3. **Config** (Configuración)
Configuraciones globales de la aplicación.

- **routes/**: Configuración de navegación
- **environment/**: Variables de entorno (dev, staging, prod)

### 4. **Features** (Funcionalidades)
Cada feature es independiente y sigue Clean Architecture:

#### **Domain** (Dominio)
- **entities/**: Objetos de negocio puros (sin dependencias externas)
- **repositories/**: Interfaces (contratos) de repositorios
- **usecases/**: Lógica de negocio específica

**Regla**: El dominio NO depende de nada más, es puro Dart

#### **Data** (Datos)
- **models/**: Modelos con serialización JSON
- **datasources/**: Comunicación con APIs, bases de datos, etc.
- **repositories/**: Implementación concreta de las interfaces del dominio

**Regla**: Data implementa los contratos definidos en Domain

#### **Presentation** (Presentación)
- **bloc/**: Manejo de estado con BLoC
- **pages/**: Pantallas completas
- **widgets/**: Widgets específicos del feature

**Regla**: Presentation solo habla con Domain (usecases)

## 🔄 Flujo de Datos

```
UI (Widget)
  ↓ emit event
BLoC
  ↓ calls
UseCase (Domain)
  ↓ uses
Repository Interface (Domain)
  ↑ implements
Repository Implementation (Data)
  ↓ uses
DataSource (Data)
  ↓ fetches
API / Local DB
```

## 📦 Barrel Files (Exports)

Cada carpeta principal tiene un archivo barrel para simplificar imports:

```dart
// ❌ Antes (múltiples imports)
import 'package:app/core/constants/app_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/validators.dart';

// ✅ Después (un solo import)
import 'package:app/core/core.dart';
```

## 🎯 Cómo Agregar un Nuevo Feature

1. **Crear la estructura de carpetas**:
```bash
features/mi_feature/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/
└── mi_feature.dart (barrel file)
```

2. **Empezar por Domain**:
   - Definir entidades
   - Definir interfaces de repositorios
   - Crear casos de uso

3. **Implementar Data**:
   - Crear modelos (con fromJson/toJson)
   - Implementar datasources
   - Implementar repositorios

4. **Crear Presentation**:
   - Crear BLoC (events, states, bloc)
   - Crear páginas
   - Crear widgets específicos

5. **Crear barrel file** para exports limpios

## 🛠️ Dependencias Principales

- **flutter_bloc**: Manejo de estado
- **equatable**: Comparación de objetos
- **dartz**: Programación funcional (Either para errores)
- **dio**: Cliente HTTP
- **go_router**: Navegación
- **shared_preferences**: Almacenamiento local
- **firebase_auth**: Autenticación

## ✅ Buenas Prácticas

1. **No repetir código**: Usar `core/` y `shared/` para reutilizar
2. **Separación de responsabilidades**: Cada capa tiene un propósito claro
3. **Dependency Injection**: Inyectar dependencias (repositorios, servicios)
4. **Inmutabilidad**: Usar `const` cuando sea posible
5. **Tipado fuerte**: Evitar `dynamic`, usar tipos específicos
6. **Manejo de errores**: Usar `Either<Failure, Success>` de dartz
7. **Testing**: Cada capa debe ser testeable independientemente

## 📚 Recursos

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Dartz Package](https://pub.dev/packages/dartz)
