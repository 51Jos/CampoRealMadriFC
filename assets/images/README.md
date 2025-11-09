# Assets - Imágenes

## Logo del Real Madrid FC

Para que la aplicación muestre correctamente el logo, debes agregar el archivo de imagen en la carpeta `src/images/`:

### Ubicación del logo:
```
src/images/logo.jpeg
```

### Características recomendadas:
- **Formato**: JPEG o PNG con fondo transparente
- **Tamaño**: 512x512 px (o proporcional)
- **Peso**: Máximo 500KB

### Opciones:

1. **Si tienes el logo**:
   - Copia el archivo `logo.jpeg` en la carpeta `src/images/`
   - El logo aparecerá automáticamente en la pantalla de login

2. **Si no tienes el logo**:
   - La app mostrará un icono de balón de fútbol como placeholder
   - Puedes descargar un logo del Real Madrid FC desde:
     - Sitio oficial
     - Recursos de diseño libres de derechos

3. **Logo temporal**:
   - Puedes usar cualquier logo de 512x512 para probar la app
   - Renómbralo como `logo.jpeg` y colócalo en `src/images/`

---

**Nota**: El logo actual está configurado para mostrarse en:
- Pantalla de Login
- (Próximamente) Pantalla principal y otras secciones

Si cambias el nombre del archivo, actualiza la referencia en:
- `lib/features/auth/presentation/pages/login_page.dart` (línea 275)
- `pubspec.yaml` (sección assets)
