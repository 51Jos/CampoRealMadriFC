# 🏟️ Sintético Lima

Sistema de control y gestión para canchas sintéticas.

## 📁 Estructura del Proyecto

Este proyecto utiliza **Clean Architecture** con **organización por features** para mantener un código limpio, escalable y mantenible.

```
lib/
├── core/              # 🔧 Código reutilizable global
├── shared/            # 🔄 Componentes compartidos
├── config/            # ⚙️  Configuraciones
├── features/          # 🎯 Funcionalidades por módulos
├── main.dart          # 🚀 Punto de entrada
└── firebase_options.dart
```

### 🔧 Core (Núcleo Global)
Código fundamental que se usa en toda la app:
- **constants/** - Constantes globales (URLs, timeouts, strings)
- **theme/** - Temas y colores
- **utils/** - Validadores, formateadores
- **errors/** - Manejo de errores
- **network/** - Cliente HTTP (Dio)
- **extensions/** - Extensiones útiles

### 🔄 Shared (Compartido)
Componentes reutilizables entre features:
- **widgets/** - Custom Button, TextField, Loading, Empty State
- **services/** - Storage Service (SharedPreferences)

### ⚙️ Config (Configuración)
- **routes/** - Configuración de navegación (GoRouter)
- **environment/** - Variables de entorno (dev, staging, prod)

### 🎯 Features (Funcionalidades)
Cada feature sigue Clean Architecture con 3 capas:

```
feature_name/
├── domain/           # Reglas de negocio
│   ├── entities/     # Objetos de negocio puros
│   ├── repositories/ # Interfaces (contratos)
│   └── usecases/     # Lógica de negocio
├── data/             # Implementación de datos
│   ├── models/       # Modelos con JSON
│   ├── datasources/  # APIs, DB local
│   └── repositories/ # Implementación de contratos
└── presentation/     # UI y estado
    ├── bloc/         # BLoC (manejo de estado)
    ├── pages/        # Pantallas
    └── widgets/      # Widgets del feature
```

## 🏗️ Arquitectura Implementada

### Capas de Clean Architecture

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (UI, BLoC, Pages, Widgets)            │
│  • Muestra datos al usuario             │
│  • Captura interacciones                │
└────────────┬────────────────────────────┘
             │ depende de ↓
┌────────────▼────────────────────────────┐
│          DOMAIN LAYER                   │
│  (Entities, UseCases, Repositories)     │
│  • Lógica de negocio pura               │
│  • Independiente de frameworks          │
└────────────▲────────────────────────────┘
             │ implementado por ↑
┌────────────┴────────────────────────────┐
│           DATA LAYER                    │
│  (Models, DataSources, Repositories)    │
│  • Obtiene datos de APIs/DB             │
│  • Implementa interfaces del dominio    │
└─────────────────────────────────────────┘
```

### Flujo de Datos

```
Usuario → Widget → BLoC → UseCase → Repository → DataSource → API
                     ↓
                  Estado actualizado ← Response ←────────────────┘
```

## 📦 Dependencias Principales

```yaml
# Estado y arquitectura
flutter_bloc: ^8.1.6      # Manejo de estado
equatable: ^2.0.5         # Comparación de objetos
dartz: ^0.10.1            # Either para manejo de errores

# Network
dio: ^5.7.0               # Cliente HTTP

# Firebase
firebase_core: ^4.2.1
firebase_auth: ^6.1.2

# Utilidades
intl: ^0.19.0             # Formateo de fechas/números

# Storage
shared_preferences: ^2.3.3 # Almacenamiento local

# Routing
go_router: ^14.6.2        # Navegación
```

## 🚀 Cómo Empezar

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Ejecutar la app
```bash
flutter run
```

### 3. Generar código (si usas build_runner)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📚 Uso de la Estructura

### Importar código usando Barrel Files

```dart
// ✅ Recomendado - Import limpio
import 'package:sinteticolima/core/core.dart';
import 'package:sinteticolima/shared/shared.dart';
import 'package:sinteticolima/features/auth/auth.dart';

// ❌ Evitar - Múltiples imports
import 'package:sinteticolima/core/constants/app_constants.dart';
import 'package:sinteticolima/core/theme/app_colors.dart';
import 'package:sinteticolima/core/utils/validators.dart';
```

### Ejemplo: Validar formulario

```dart
import 'package:sinteticolima/core/core.dart';
import 'package:sinteticolima/shared/shared.dart';

CustomTextField(
  label: 'Email',
  validator: Validators.combine([
    Validators.required,
    Validators.email,
  ]),
)
```

### Ejemplo: Formatear datos

```dart
import 'package:sinteticolima/core/core.dart';

Text(Formatters.currency(1500.50));    // "S/. 1,500.50"
Text(Formatters.date(DateTime.now())); // "05/11/2025"
Text(Formatters.phone("987654321"));   // "987 654 321"
```

### Ejemplo: Usar extensiones

```dart
import 'package:sinteticolima/core/core.dart';

// String extensions
"hola mundo".capitalizeWords(); // "Hola Mundo"
"test@email.com".isValidEmail;  // true

// Context extensions
context.showSuccessSnackBar("¡Guardado!");
context.hideKeyboard();
context.screenWidth; // Ancho de pantalla
```

## ➕ Agregar un Nuevo Feature

1. **Crear estructura de carpetas:**
```bash
features/
└── nuevo_feature/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    ├── data/
    │   ├── models/
    │   ├── datasources/
    │   └── repositories/
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

2. **Empezar por Domain** (reglas de negocio)
3. **Implementar Data** (obtención de datos)
4. **Crear Presentation** (UI y BLoC)
5. **Crear barrel file** `nuevo_feature.dart`

Ver documentación completa en [ARCHITECTURE.md](ARCHITECTURE.md)

## 📖 Documentación

- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura completa del proyecto
- [lib/core/README.md](lib/core/README.md) - Documentación de Core
- [lib/features/README.md](lib/features/README.md) - Guía de Features

## ✅ Ventajas de esta Estructura

- ✨ **Sin código duplicado**: Todo reutilizable está en `core/` y `shared/`
- 🧩 **Modular**: Features independientes
- 🧪 **Testeable**: Cada capa se testea independientemente
- 🔧 **Mantenible**: Fácil encontrar y modificar código
- 🚀 **Escalable**: Agregar features sin afectar otros
- 📦 **Imports limpios**: Barrel files simplifican imports

## 🎯 Reglas de Oro

1. ✅ **Core NO importa features** - El núcleo es independiente
2. ✅ **Shared NO importa features** - Componentes compartidos son genéricos
3. ✅ **Domain es puro Dart** - Sin dependencias de Flutter/Firebase
4. ✅ **Data implementa Domain** - Las interfaces las define el dominio
5. ✅ **Presentation usa UseCases** - La UI solo habla con casos de uso
6. ✅ **Un feature = una carpeta** - Todo relacionado está junto
7. ✅ **Barrel files siempre** - Exports limpios en cada módulo

## 👨‍💻 Desarrollo

### Ejemplo de Feature Auth Incluido

El proyecto incluye un feature de autenticación completo como ejemplo:
- Login con email/password
- Integración con Firebase Auth
- BLoC para manejo de estado
- Validaciones de formulario
- Manejo de errores

Ver código en `lib/features/auth/`

## 🔐 Variables de Entorno

Configurar entornos en `lib/config/environment/env_config.dart`:

```dart
EnvConfig.setEnvironment(Environment.development);
print(EnvConfig.baseUrl); // URL según ambiente
```

## 🗺️ Rutas

Configuración centralizada en `lib/config/routes/app_router.dart` usando GoRouter.

## 🎨 Tema

Personalizar colores y tema en:
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`

---

**Desarrollado con Flutter & Clean Architecture** 🚀
