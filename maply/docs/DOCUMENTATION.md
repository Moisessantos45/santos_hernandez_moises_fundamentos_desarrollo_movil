# Documentación Técnica — Maply (Mis Lugares Favoritos)

**Maply** es una aplicación móvil desarrollada en Flutter para la gestión y visualización geográfica de lugares favoritos personales (restaurantes, cafeterías, lugares de estudio, hogar, gimnasios, etc.) utilizando **Supabase** como backend en la nube y **OpenStreetMap** con `flutter_map`.

---

## 1. Arquitectura del Proyecto

El proyecto está organizado siguiendo una arquitectura limpia y modular dividida por responsabilidades:

```
lib/
├── config/
│   ├── api.dart              # Instancia singleton de Dio con timeouts configurados
│   └── app_config.dart       # Variables de entorno cargadas vía dart-define
├── models/
│   └── place.dart            # Modelo Place con serialización segura (sin casteos inseguros)
├── presentation/
│   ├── screens/
│   │   ├── add_edit_place_screen.dart # Formulario de creación y edición con selector en mapa y GPS
│   │   ├── home_screen.dart           # Navegación principal con pestañas (Mapa / Lista)
│   │   ├── login.dart                 # Autenticación (Login / Registro) con Supabase
│   │   ├── map_screen.dart            # Mapa interactivo OpenStreetMap con pines por categoría
│   │   ├── places_list_screen.dart    # Lista de lugares con buscador y filtros
│   │   ├── place_detail_screen.dart   # Vista detallada de un lugar con minimapa
│   │   └── profile_screen.dart        # Perfil de usuario, estadísticas y cierre de sesión
│   └── widgets/
│       ├── category_badge.dart        # Badge de categoría con ícono y color temático
│       ├── category_filter_bar.dart   # Barra de filtros horizontales por categoría
│       ├── custom_button.dart         # Botón estándar estilizado con soporte de carga
│       ├── custom_text_field.dart     # Campo de texto personalizado con validación
│       ├── delete_dialog.dart         # Diálogo modal de confirmación para eliminar
│       ├── map_picker_dialog.dart     # Selector modal de coordenadas en mapa
│       ├── place_card.dart            # Tarjeta de lugar con decodificación de imagen optimizada
│       └── widgets.dart               # Archivo de barril con exportaciones relativas
├── services/
│   ├── location_service.dart # Servicio de geolocalización GPS con geolocator
│   └── supabase_service.dart # Cliente Supabase para Auth y CRUD de base de datos
└── main.dart                 # Punto de entrada e inicialización de servicios
```

---

## 2. Backend y Base de Datos (Supabase)

### Autenticación
- **Flujo de Registro**: Creación de cuenta con correo y contraseña vía `Supabase.instance.client.auth.signUp()`.
- **Inicio de Sesión**: Autenticación persistente con `signInWithPassword()`.
- **Confirmación por correo**: La app permite el acceso directo una vez creada la cuenta si la confirmación por correo está desactivada en el panel de Supabase (*Authentication > Providers > Email > Confirm email = OFF*).

### Esquema de Datos (`places`)
El script SQL para inicializar la base de datos se encuentra en `supabase/schema.sql`:

```sql
create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  title text not null,
  description text default '',
  category text not null default 'General',
  latitude double precision not null,
  longitude double precision not null,
  image_url text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### Seguridad y Aislamiento (Row Level Security - RLS)
Se aplican políticas RLS para garantizar que cada usuario únicamente tenga acceso a sus propios lugares:

1. **Lectura (`SELECT`)**:
   ```sql
   create policy "Users can view their own places"
     on public.places for select to authenticated
     using ((select auth.uid()) = user_id);
   ```
2. **Inserción (`INSERT`)**:
   ```sql
   create policy "Users can create their own places"
     on public.places for insert to authenticated
     with check ((select auth.uid()) = user_id);
   ```
3. **Actualización (`UPDATE`)**:
   ```sql
   create policy "Users can update their own places"
     on public.places for update to authenticated
     using ((select auth.uid()) = user_id)
     with check ((select auth.uid()) = user_id);
   ```
4. **Eliminación (`DELETE`)**:
   ```sql
   create policy "Users can delete their own places"
     on public.places for delete to authenticated
     using ((select auth.uid()) = user_id);
   ```

---

## 3. Mapas y Geolocalización

- **Proveedor de Mapas**: OpenStreetMap (OSM) mediante la librería `flutter_map` versión `8.3.0` y `latlong2`.
- **Servidor de Tiles**: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`.
- **Geolocalización GPS**: Manejo de permisos (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) mediante `LocationService` para ubicar al usuario y centrar la vista.
- **Selector Interactivo**: `MapPickerDialog` permite fijar un punto tocando cualquier parte del mapa o utilizando la posición actual de GPS.

---

## 4. Categorías y Sistema Visual

Cada categoría cuenta con un color característico y un ícono dedicado:

| Categoría | Color | Ícono |
| :--- | :--- | :--- |
| **Comida** | `#F97316` (Naranja) | `Icons.restaurant_rounded` |
| **Estudio** | `#6366F1` (Índigo) | `Icons.school_rounded` |
| **Diversión** | `#EC4899` (Rosa) | `Icons.celebration_rounded` |
| **Hogar** | `#10B981` (Esmeralda) | `Icons.home_rounded` |
| **Deporte** | `#F59E0B` (Ámbar) | `Icons.fitness_center_rounded` |
| **Café** | `#8D6E63` (Marrón) | `Icons.local_cafe_rounded` |
| **Otro** | `#2563EB` (Azul) | `Icons.place_rounded` |

---

## 5. Gestión de Estado con `ValueNotifier`

Para maximizar el rendimiento y evitar reconstrucciones completas de la interfaz mediante `setState`:
- Los estados de carga (`isLoading`), variables de búsqueda (`searchQuery`), filtros de categoría (`selectedCategory`) y posiciones geográficas (`selectedPoint`, `userLocation`) están encapsulados en instancias de `ValueNotifier`.
- Los widgets escuchan únicamente el cambio necesario a través de `ValueListenableBuilder`.

---

## 6. Configuración de Variables de Entorno

Las variables de conexión se definen en el archivo `env.dev.json`:

```json
{
  "SUPABASE_URL": "https://lswrefspqggtfdtbgbad.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_sLndhEuXcF4chwpgDugOmg_W3RitByu",
  "APPWRITE_PROJECT_ID": "6ac8846200133244020d",
  "APPWRITE_PROJECT_NAME": "My first project",
  "APPWRITE_ENDPOINT": "http://192.168.100.54/v1"
}
```

Para compilar y ejecutar pasando el archivo de configuración:

```bash
flutter run --dart-define-from-file=./env.dev.json
```
