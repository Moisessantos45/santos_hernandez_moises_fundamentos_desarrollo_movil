# 📍 Maply — Mis Lugares Favoritos

[![Descargar APK](https://img.shields.io/badge/Descargar%20APK-Maply-2563EB?style=for-the-badge&logo=android&logoColor=white)](https://zurl.mmabitec.uk/kLkJDb)

**Maply** es una aplicación móvil desarrollada en Flutter para guardar, organizar y explorar tus lugares favoritos (cafeterías, restaurantes, gimnasios, lugares de estudio, casa, etc.) en un mapa interactivo de OpenStreetMap con sincronización en la nube a través de Supabase.

---

## 📥 Descarga de la Aplicación

Puedes descargar el archivo APK de instalación directamente desde el siguiente enlace:

👉 **[Descargar Maply APK (Android)](https://zurl.mmabitec.uk/kLkJDb)**

---

## ✨ Características Principales

- 🔐 **Autenticación con Supabase**: Registro e inicio de sesión seguro con sesión persistente y cierre de sesión.
- 🗺️ **Mapa Interactivo con OpenStreetMap**: Visualización de pines personalizados por categoría y ubicación GPS en tiempo real.
- 📌 **CRUD de Lugares Favoritos**: Creación, listado, edición y eliminación de lugares con confirmación.
- 🎯 **Selector de Ubicación**: Selección de puntos geográficos interactuando directamente sobre el mapa o utilizando el GPS del teléfono.
- 🏷️ **Filtros y Búsqueda**: Búsqueda instantánea por nombre o descripción y filtrado por categorías temáticas (Comida, Estudio, Diversión, Hogar, Deporte, Café, Otro).
- 🖼️ **Fotos de Lugares**: Soporte para imágenes de portada con decodificación en memoria optimizada (`cacheWidth`).
- 👤 **Perfil y Estadísticas**: Conteo total de lugares guardados y desglose estadístico por categorías.
- ⚡ **Rendimiento Óptimo**: Estado reactivo con `ValueNotifier` y `ValueListenableBuilder` para 60/120 FPS fluidos.

---

## 🛠️ Stack Tecnológico

| Herramienta | Uso |
| :--- | :--- |
| **Flutter 3.x & Dart** | Framework y lenguaje de desarrollo |
| **Supabase Flutter** | Autenticación y Base de datos PostgreSQL |
| **OpenStreetMap & flutter_map (v8.3.0)** | Renderizado de mapas sin dependencias de Google Maps |
| **Geolocator** | Acceso al GPS del dispositivo |
| **Dio** | Cliente HTTP optimizado con timeouts |
| **latlong2** | Cálculos y manejo de coordenadas |

---

## 🚀 Inicio Rápido

### 1. Requisitos Previos
- Flutter SDK instalado (`^3.12.0+`).
- Emulador Android o dispositivo físico conectado.

### 2. Configuración de Base de Datos (Supabase)
Ejecuta el script [supabase/schema.sql](file:///home/moy45/proyectos_flutter/santos_hernandez_moises_fundamentos_desarrollo_movil/maply/supabase/schema.sql) en el SQL Editor de tu proyecto en Supabase para crear la tabla `places` y habilitar las políticas de seguridad **Row Level Security (RLS)**.

> **Importante**: Para permitir que los nuevos usuarios registrados puedan acceder inmediatamente sin requerir verificación por correo, desactiva la confirmación en:  
> *Supabase Dashboard > Authentication > Providers > Email > Confirm email = OFF*.

### 3. Ejecutar la Aplicación

Para ejecutar la aplicación con el archivo de variables de entorno:

```bash
flutter run --dart-define-from-file=./env.dev.json
```

---

## 📁 Estructura del Proyecto

```
lib/
├── config/                  # Configuraciones globales (Dio, variables de entorno)
├── models/                  # Modelo de datos Place
├── presentation/
│   ├── screens/             # Pantallas (Login, Home, Map, PlacesList, PlaceDetail, AddEdit, Profile)
│   └── widgets/             # Widgets reutilizables con archivo de barril widgets.dart
├── services/                # Servicios de Supabase y Geolocalización GPS
└── main.dart                # Inicialización de la aplicación
```

---

## 📚 Documentación Adicional

- 📖 [Documentación Técnica Completa](docs/DOCUMENTATION.md)
- ⚡ [Guía de Optimizaciones para Android](docs/OPTIMIZATIONS.md)
- 📋 [Requerimientos del Proyecto](docs/requerimens.txt)
- 🗄️ [Esquema SQL de Supabase](supabase/schema.sql)
