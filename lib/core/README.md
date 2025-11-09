# Core

Esta carpeta contiene el **código fundamental** que se reutiliza en toda la aplicación y no depende de ningún feature específico.

## 📂 Estructura

### constants/
Constantes globales de la aplicación:
- `app_constants.dart`: URLs, timeouts, configuraciones
- `app_strings.dart`: Textos estáticos (antes de i18n)

**Ejemplo de uso**:
```dart
import 'package:sinteticolima/core/core.dart';

print(AppConstants.baseUrl);
print(AppStrings.genericError);
```

### theme/
Temas visuales y estilos:
- `app_colors.dart`: Paleta de colores
- `app_theme.dart`: Tema de Material Design

**Ejemplo de uso**:
```dart
import 'package:sinteticolima/core/core.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
);

Container(color: AppColors.primary);
```

### utils/
Utilidades reutilizables:
- `validators.dart`: Validadores para formularios
- `formatters.dart`: Formateadores (moneda, fechas, etc.)

**Ejemplo de uso**:
```dart
import 'package:sinteticolima/core/core.dart';

TextFormField(
  validator: Validators.combine([
    Validators.required,
    Validators.email,
  ]),
);

Text(Formatters.currency(1500.50)); // "S/. 1,500.50"
```

### errors/
Manejo centralizado de errores:
- `failures.dart`: Clases de error (ServerFailure, NetworkFailure, etc.)

**Ejemplo de uso**:
```dart
import 'package:sinteticolima/core/core.dart';

if (!networkAvailable) {
  return Left(NetworkFailure());
}
```

### network/
Cliente HTTP centralizado:
- `api_client.dart`: Cliente Dio configurado
- `network_info.dart`: Verificación de conectividad

**Ejemplo de uso**:
```dart
import 'package:sinteticolima/core/core.dart';

final client = ApiClient();
final response = await client.get('/users');
```

### extensions/
Extensiones útiles para tipos nativos:
- `string_extensions.dart`: Extensiones para String
- `context_extensions.dart`: Extensiones para BuildContext

**Ejemplo de uso**:
```dart
import 'package:sinteticolima/core/core.dart';

String text = "hola mundo";
print(text.capitalizeWords()); // "Hola Mundo"

context.showSuccessSnackBar("¡Éxito!");
context.hideKeyboard();
```

## 🚫 Reglas Importantes

1. **NO importar features**: El core no debe depender de ningún feature
2. **NO importar shared**: El core es independiente
3. **Solo Dart puro o Flutter básico**: Sin dependencias de features
4. **Altamente reutilizable**: Todo aquí debe usarse en múltiples lugares

## 📦 Import Simplificado

Usa el barrel file para importar todo el core:

```dart
// ✅ Recomendado
import 'package:sinteticolima/core/core.dart';

// ❌ Evitar múltiples imports
import 'package:sinteticolima/core/constants/app_constants.dart';
import 'package:sinteticolima/core/theme/app_colors.dart';
```
