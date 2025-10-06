# 🌮 Un Lugar Chido

<p align="center">
  <img src="assets/images/logoChido.png" alt="Un Lugar Chido Logo" width="200"/>
</p>

<p align="center">
  <strong>Una aplicación móvil para administrar el menú de un restaurante mexicano.</strong>
  <br />
  <br />
  <a href="https://github.com/d-pombo/Un-Lugar-Chido-main/stargazers"><img src="https://img.shields.io/github/stars/d-pombo/Un-Lugar-Chido-main?style=social" alt="GitHub Stars"></a>
  <a href="https://github.com/d-pombo/Un-Lugar-Chido-main/network/members"><img src="https://img.shields.io/github/forks/d-pombo/Un-Lugar-Chido-main?style=social" alt="GitHub Forks"></a>
  <a href="https://github.com/d-pombo/Un-Lugar-Chido-main/blob/main/LICENSE"><img src="https://img.shields.io/github/license/d-pombo/Un-Lugar-Chido-main" alt="License"></a>
</p>

---

## 📌 Descripción

"Un Lugar Chido" es una aplicación demo construida con Flutter que sirve como un sistema de gestión de menús para un restaurante. Permite a los administradores gestionar los productos y a los clientes ver el menú a través de un código QR.

La aplicación está diseñada para ser de código abierto, demostrando cómo manejar secretos y claves de API de forma segura en un repositorio público de GitHub.

## 🚀 Características

- **Catálogo de Productos:** Menú y barra de bebidas por categorías.
- **Panel de Administración:** Funcionalidades CRUD (Crear, Leer, Actualizar, Eliminar) para los productos.
- **Almacenamiento de Imágenes:** Sube y almacena imágenes de productos en Supabase Storage.
- **Autenticación:** Inicio de sesión seguro para administradores con Supabase Auth.
- **Código QR:** Genera un código QR para que los clientes puedan acceder al menú fácilmente.
- **Navegación Moderna:** Utiliza GoRouter para una navegación fluida y basada en rutas.

## 🛠️ Tech Stack

- **Frontend:** Flutter
- **Backend & Base de Datos:** Supabase
- **Navegación:** GoRouter
- **Gestión de Estado:** setState / ValueNotifier (implícito)
- **Dependencias Principales:**
  - `supabase_flutter`
  - `go_router`
  - `qr_flutter`
  - `cached_network_image`
  - `image_picker`
  - `file_picker`

## 🏁 Cómo Empezar

Sigue estos pasos para ejecutar el proyecto localmente.

### Pre-requisitos

- Flutter SDK (versión >= 3.5)
- Una cuenta y un proyecto en [Supabase](https://supabase.com/)

### Instalación y Ejecución

1.  **Clona el repositorio:**
    ```bash
    git clone https://github.com/DonPombo/Un-Lugar-Chido-main.git
    cd Un-Lugar-Chido-main
    ```

2.  **Instala las dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Configura tus secretos de Supabase:**

    Crea un archivo `supabase.env` en la raíz del proyecto. Este archivo **no** será rastreado por Git.

    ```
    SUPABASE_URL=https://<tu-proyecto>.supabase.co
    SUPABASE_ANON_KEY=<tu-anon-key>
    ```

    > **Nota:** Puedes encontrar un ejemplo en `supabase.env.example`.

4.  **Ejecuta la aplicación:**

    Utiliza el siguiente comando para pasar las variables de entorno a la aplicación en tiempo de ejecución:

    ```bash
    flutter run --dart-define-from-file=supabase.env
    ```

## 🔐 Seguridad y CI/CD

Este proyecto demuestra cómo mantener un repositorio público sin exponer credenciales sensibles.

- **Variables de Entorno:** Las claves de Supabase se cargan desde un archivo `.env` local (ignorado por Git) o desde secretos en un entorno de CI/CD.
- **GitHub Actions:** El archivo `.github/workflows/main.yml` (si existe) puede ser configurado para construir la aplicación pasando los secretos de forma segura.

**Ejemplo de un paso de build en GitHub Actions:**
```yaml
- name: Build APK
  run: |
    flutter pub get
    flutter build apk --release --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

## 📁 Estructura del Proyecto

```
lib/
├── admin screens/      # Pantallas de administración
├── models/             # Modelos de datos (Producto, Usuario)
├── pages/              # Pantallas principales de la app (Home, Catálogo, etc.)
├── router/             # Configuración de GoRouter
├── services/           # Lógica de negocio (Auth, Supabase, etc.)
├── Theme/              # Tema de la aplicación
└── main.dart           # Punto de entrada de la app
```

## 🤝 Cómo Contribuir

Las contribuciones son bienvenidas. Si deseas contribuir, por favor sigue estos pasos:

1.  Haz un Fork del proyecto.
2.  Crea una nueva rama (`git checkout -b feature/nueva-funcionalidad`).
3.  Realiza tus cambios y haz commit (`git commit -m 'Añade nueva funcionalidad'`).
4.  Haz push a la rama (`git push origin feature/nueva-funcionalidad`).
5.  Abre un Pull Request.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

Desarrollado con ❤️ por [d-pombo](https://github.com/d-pombo)