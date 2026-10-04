# Arquitectura y Estructura del Proyecto

MusicX está estructurada siguiendo principios de código limpio (*Clean Architecture*) y separación de responsabilidades, optimizada para rendimiento y mantenibilidad.

---

## 1. Estructura de Directorios

```
lib/
├── config/
│   └── environment.dart          # Lectura de variables de entorno pasadas por dart-define
├── models/
│   └── song_model.dart           # Modelo inmutable de Canción (fromJson, toJson, copyWith)
├── services/
│   └── supabase_service.dart     # Servicio singleton para Auth y CRUD en Supabase
├── presentation/
│   ├── screens/                  # Vistas completas de la aplicación
│   │   ├── splash_screen.dart    # Verificación de sesión y enrutamiento inicial
│   │   ├── login_screen.dart     # Autenticación con email y contraseña
│   │   ├── register_screen.dart  # Registro de nuevos usuarios
│   │   ├── home_screen.dart      # Lista de canciones con pull-to-refresh y logout
│   │   └── song_form_screen.dart # Creación y edición de canciones con preview
│   └── widgets/                  # Widgets modulares y reutilizables
│       ├── custom_text_field.dart# Campo de texto estilizado
│       ├── song_card.dart        # Tarjeta visual de cada canción
│       └── empty_songs_view.dart # Estado vacío cuando no hay canciones
└── main.dart                     # Punto de entrada, inicialización de Supabase y tema
```

---

## 2. Gestión de Estado Reactivo (`ValueNotifier`)

En lugar de reconstruir árboles completos de widgets mediante `setState()`, la aplicación utiliza `ValueNotifier` y `ValueListenableBuilder`:

- **Aislamiento de renderizado**: Únicamente los widgets envueltos en `ValueListenableBuilder` se reconstruyen cuando cambia el valor.
- **Liberación de recursos**: Todos los `ValueNotifier` se cierran adecuadamente en el método `dispose()` de sus respectivos `StatefulWidget`.
- **Variables controladas**: Indicadores de carga (`_isLoadingNotifier`), mensajes de error (`_errorMessageNotifier`), visibilidad de contraseñas (`_obscurePasswordNotifier`) y lista de datos (`_songsNotifier`).

---

## 3. Importaciones Limpias

Todas las referencias dentro del proyecto utilizan importaciones de paquete absoluto:
```dart
import 'package:musicx/models/song_model.dart';
import 'package:musicx/services/supabase_service.dart';
import 'package:musicx/presentation/widgets/custom_text_field.dart';
```

---

## 4. Control de Navegación y Rutas Protegidas

- **Rutas públicas (`LoginScreen`, `RegisterScreen`)**: Si el usuario ya posee una sesión activa, se redirige inmediatamente a `HomeScreen`.
- **Ruta protegida (`HomeScreen`)**: Previene la navegación hacia atrás mediante `PopScope(canPop: false)`. El usuario solo puede salir de la vista protegida cerrando sesión explícitamente, lo cual limpia el historial de navegación con `Navigator.pushAndRemoveUntil`.
