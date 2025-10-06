🌮 Un Lugar Chido

Aplicación móvil construida con Flutter para mostrar y administrar el menú de un restaurante mexicano. Pensada para ser pública en GitHub sin exponer credenciales sensibles (Supabase keys, Google services, etc.).

---

Contenido rápido:

- Descripción
- Características
- Cómo ejecutar localmente (y mantener secretos fuera del repo)
- Cómo desplegar / CI (GitHub Actions)
- Estructura del proyecto
- Observaciones y checklist de seguridad

---

## 📌 Descripción

"Un Lugar Chido" es una app demo que muestra un catálogo de productos (comida y barra), genera un QR para el menú, y trae un panel de administración para CRUD de productos en tiempo real usando Supabase.

El repositorio puede publicarse en GitHub. Todas las claves y credenciales deben mantenerse fuera del control de versiones mediante variables de entorno o secretos de CI.

## 🚀 Características

- Catálogo por categorías (Menú / Barra)
- Panel administrador con alta/edición/eliminación de productos
- Subida de imágenes y almacenamiento en Supabase
- Autenticación Supabase para administración
- QR para acceder al menú desde dispositivos móviles
- Navegación con GoRouter

## 🧩 Requisitos

- Flutter SDK (recomendado >= 3.5)
- Cuenta y proyecto en Supabase

## 🔐 Seguridad: cómo mantener el repo público

1. No incluir claves en el código.
	 - Ya se removieron las claves hard-coded de `lib/main.dart`.
2. Añade las claves localmente en un archivo no rastreado por git (ej.: `supabase.env`) o pásalas en tiempo de ejecución con `--dart-define`.
3. Usa `supabase.env.example` (incluido) como plantilla pública.
4. Configura secretos en tu CI (GitHub Actions) y pásalos como `--dart-define` al compilar.

### Ejemplo (local, recomendado):

1. Crea `supabase.env` en la raíz (NO subirlo):

```
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiI...
```

2. Carga las variables y ejecuta (PowerShell):

```powershell
# Cargar manualmente las variables desde el archivo .env (ejemplo simple para PowerShell)
$lines = Get-Content .\supabase.env
foreach ($line in $lines) {
	if ($line -match "^([^=]+)=(.*)$") {
		$name = $matches[1]
		$value = $matches[2]
		Set-Item -Path Env:\$name -Value $value
	}
}

flutter run --dart-define=SUPABASE_URL=$env:SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

O, sin exportar variables, pásalas directamente (menos seguro):

```powershell
flutter run --dart-define=SUPABASE_URL=https://<tu-proyecto>.supabase.co --dart-define=SUPABASE_ANON_KEY=<TU_ANON_KEY>
```

### Ejemplo (GitHub Actions deployment snippet)

```yaml
jobs:
	build:
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v4
			- name: Install Flutter
				uses: subosito/flutter-action@v2
				with:
					flutter-version: 'stable'
			- name: Build APK
				run: |
					flutter pub get
					flutter build apk --release --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

Agrega `SUPABASE_URL` y `SUPABASE_ANON_KEY` como Secrets del repositorio (Settings → Secrets).

## 🧭 Cómo ejecutar (desarrollo)

1. Instala dependencias:

```powershell
flutter pub get
```

2. Ejecuta en dispositivo/emulador pasando las credenciales (ver sección anterior):

```powershell
flutter run --dart-define=SUPABASE_URL=https://<tu-proyecto>.supabase.co --dart-define=SUPABASE_ANON_KEY=<TU_ANON_KEY>
```

3. Tests:

```powershell
flutter test
```

> Nota: el test de ejemplo en `test/widget_test.dart` espera un contador. Puedes actualizar las pruebas a la lógica real de la app o eliminar/ajustar el test si no aplica.

## 📁 Estructura importante

- `lib/main.dart` — inicialización de Supabase (lee variables en tiempo de compilación).
- `lib/services/` — servicios de Supabase, auth y subida de imágenes.
- `lib/admin screens/` — pantallas y diálogos de administración.
- `assets/images/` — imágenes usadas en la app.

## ✅ Checklist antes de publicar el repo

- [x] Quitar keys hard-coded
- [x] Añadir `supabase.env.example` con placeholders
- [x] Añadir `.gitignore` que excluya secretos y builds
- [ ] Revisar `android/app/google-services.json` y `ios` si contienen identificadores sensibles (no subirlos si son privados)
- [ ] Remplazar URLs y links de redes sociales por reales

## Observaciones y recomendaciones rápidas

- Revisa todas las rutas a assets (p.ej. `assets/images/logoChido.png`) y confirma que no haya rutas absolutas.
- Considera meter la lógica de lectura de credenciales en un helper para facilitar tests.
- Añade más tests: unidad de `SupabaseService` (mock client) y tests widget para rutas principales.

---

Si quieres, puedo:

- Añadir un pequeño script PowerShell en `scripts/` para cargar el `.env` y ejecutar `flutter run` con las `dart-define`.
- Crear el workflow de GitHub Actions completo para build+release.

Dime qué prefieres y lo hago.
