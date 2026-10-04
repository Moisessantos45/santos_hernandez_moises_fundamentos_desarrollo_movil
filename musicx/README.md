# MusicX 🎵

Aplicación móvil moderna en **Flutter** para la gestión personalizada de tu biblioteca musical, con autenticación segura y persistencia en la nube mediante **Supabase (PostgreSQL con Row Level Security)**.

---

## 📲 Descarga de la Aplicación

Puedes descargar e instalar la versión de producción directamente desde el siguiente enlace:

👉 **[Descargar APK para Android](https://zurl.mmabitec.uk/LawuIv)** (`https://zurl.mmabitec.uk/LawuIv`)

---

## ✨ Características Principales

- **Autenticación con Correo y Contraseña**: Registro e inicio de sesión sencillos y directos (sin confirmación por correo requerida).
- **Control y Seguridad Multi-Usuario (RLS)**: Cada usuario únicamente puede ver, crear, editar y eliminar sus propias canciones.
- **CRUD Completo de Canciones**:
  - Título de la pista musical.
  - Nombre del artista / grupo.
  - Portada mediante URL con previsualización en tiempo real.
  - Descripción, álbum o notas adicionales.
- **Interfaz Moderna en Modo Claro**: Diseño limpio, elegante y enfocado en usabilidad (Material 3).
- **Protección de Rutas**: Validación de sesión automática al abrir la app y bloqueo de retorno a login/registro una vez autenticado.
- **Rendimiento Optimizado**:
  - Gestión de estado reactiva con `ValueNotifier` y `ValueListenableBuilder` (sin `setState`).
  - Aislamiento de renderizado con `RepaintBoundary`.
  - Decodificación eficiente de imágenes en memoria (`cacheWidth: 800`).
  - Minificación y ofuscación R8 para producción.

---

## 📦 Paquetes y Dependencias Utilizadas

| Paquete | Versión | Propósito |
| :--- | :--- | :--- |
| **`supabase_flutter`** | `^2.18.0` | Cliente oficial de Supabase para Flutter (Autenticación, Base de datos PostgreSQL y Realtime). |
| **`cupertino_icons`** | `^1.0.8` | Íconos de estilo Cupertino para soporte multiplataforma. |
| **`flutter_lints`** | `^6.0.0` | Reglas de estilo y mejores prácticas de código para Dart y Flutter. |

---

## 🏛️ Distribución del Proyecto

La estructura de carpetas sigue una arquitectura limpia orientada a componentes:

```
lib/
├── config/                       # Configuración y variables de entorno
│   └── environment.dart          # Lectura de SUPABASE_URL y SUPABASE_ANON_KEY
├── models/                       # Modelos de datos
│   └── song_model.dart           # Modelo inmutable Song
├── services/                     # Servicios de datos y backend
│   └── supabase_service.dart     # Métodos de Auth y CRUD de canciones
├── presentation/
│   ├── screens/                  # Vistas de la aplicación
│   │   ├── splash_screen.dart    # Verificación de sesión al iniciar
│   │   ├── login_screen.dart     # Vista de Inicio de Sesión
│   │   ├── register_screen.dart  # Vista de Registro
│   │   ├── home_screen.dart      # Vista principal (Listado de canciones)
│   │   └── song_form_screen.dart # Vista de Formulario (Crear/Editar)
│   └── widgets/                  # Widgets reutilizables
│       ├── custom_text_field.dart# Campo de texto personalizado
│       ├── song_card.dart        # Tarjeta visual de la canción
│       └── empty_songs_view.dart # Estado vacío
└── main.dart                     # Entrada principal, inicialización y tema
```

---

## ⚙️ Configuración y Ejecución

### 1. Variables de Entorno (`env.dev.json`)

Crea o edita el archivo `env.dev.json` en la raíz del proyecto:

```json
{
  "SUPABASE_URL": "https://<tu-proyecto>.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_<tu-clave-publica>"
}
```

### 2. Ejecutar en Desarrollo

```bash
flutter run --dart-define-from-file=./env.dev.json
```

### 3. Compilar para Producción (Release)

```bash
flutter build apk --release --dart-define-from-file=./env.dev.json --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 📚 Documentación Adicional

Para más detalles técnicos, consulta los documentos en la carpeta [`/docs`](docs/):

- 📐 **[Arquitectura y Código Limpio](docs/ARCHITECTURE.md)**: Estructura, importaciones y `ValueNotifier`.
- 🔒 **[Base de Datos y Seguridad RLS](docs/DATABASE_AND_SECURITY.md)**: Tablas, políticas PostgreSQL y migraciones.
- 🚀 **[Compilación y Optimizaciones](docs/BUILD_AND_DEPLOYMENT.md)**: ProGuard, R8, Gradle y parámetros de rendimiento.
