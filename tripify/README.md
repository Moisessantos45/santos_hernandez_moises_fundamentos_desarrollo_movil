# Tripify

Aplicación móvil de **Reserva de Viajes** desarrollada en **Flutter** con diseño de alta fidelidad, navegación fluida, gestión reactiva de estado y optimizaciones nativas avanzadas.

---

## Descarga de la Aplicación

Puedes descargar el archivo instalador APK directamente desde el siguiente enlace:

**[Descargar Tripify APK (Google Drive)](https://drive.google.com/file/d/15wX0MmGQG897G58ePUZrgbWvrs1dqytr/view?usp=sharing)**

---

## Características Principales

### 1. Exploración y Búsqueda (`HomeScreen`)
- **Filtros por Categoría**: Avión, Autobús, Tren y Hotel.
- **Buscador Dinámico**: Filtrado en tiempo real por título, ciudad o país.
- **Tarjetas Interactivas**: Destinos populares y recomendados con soporte de favoritos.
- **Diseño Adaptativo**: Soporte responsivo para móvil y tablet (`LayoutBuilder`, `SafeArea` y `CustomScrollView`).

### 2. Detalle del Destino (`TripDetailScreen`)
- **SliverAppBar Flexible**: Imagen de cabecera inmersiva con gradientes.
- **Especificaciones Clave**: Calificación, duración, transporte sugerido y tamaño de grupo.
- **Aspectos Destacados**: Chips de experiencias destacadas y descripción completa.
- **Acción Rápida**: Botón flotante para iniciar la reserva.

### 3. Formulario de Reserva (`BookingFormScreen`)
El formulario se divide en 5 secciones reactivas estructuradas:
- **Sección 1 - Información general**: Contexto y guía del proceso.
- **Sección 2 - Datos del viajero**: Campos validados para nombre completo y correo electrónico.
- **Sección 3 - Destino y transporte**:
  - Selección visual interactiva de destino (*Playa*, *Ciudad*, *Montaña*) con retroalimentación vía `SnackBar`.
  - Selector de medio de transporte (*Avión*, *Autobús*, *Tren*, *Barco*).
- **Sección 4 - Extras y presupuesto**:
  - Servicios adicionales con casillas dinámicas (Hotel, Tour guiado, Seguro de viaje).
  - Switch interactivo para notificaciones.
  - Slider de presupuesto ajustable ($500 - $10,000 con divisiones de $500).
  - Selector de fecha de viaje mediante `DatePicker`.
- **Sección 5 - Confirmación y resumen**:
  - Modal de resumen con desglose detallado de la reserva.
  - Diálogo de validación antes de confirmar.
  - Botón de limpieza rápida en el `AppBar` para restablecer el formulario.

### 4. Boleto Digital (`TicketScreen`)
- **Boarding Pass Card**: Tarjeta de embarque con detalles del pasajero, origen/destino, fecha, extras seleccionados, código QR/barras y costo total.
- **Edición Rápida**: Opción para regresar y modificar datos.

---

## Aspectos Técnicos

- **Arquitectura Limpia**: Separación modular en capas (`core`, `data`, `domain`, `presentation`).
- **Gestión de Estado Eficiente**: Uso de `ValueNotifier` y `ListenableBuilder` con `Listenable.merge` para actualizaciones reactivas sin reconstruir árboles de widgets innecesarios.
- **Navegación Personalizada**: `CustomNavigator` con transiciones fluidas tipo `FadeTransition`.
- **Optimizaciones Nativas**:
  - Soporte de **R8** (minificación y reducción de recursos).
  - Aceleración gráfica por hardware con **Impeller**.
  - Decodificación optimizada de imágenes con `cacheWidth` y aislamiento de animaciones con `RepaintBoundary`.

---

## Ejecución del Proyecto

### Requisitos previos
- Flutter SDK 3.27+ / Dart SDK 3.6+
- Android Studio / Android SDK (Java 17)

### Comandos de ejecución

```bash
# Obtener dependencias
flutter pub get

# Ejecutar pruebas unitarias y de widgets
flutter test

# Ejecutar en modo desarrollo
flutter run

# Compilar APK optimizado para producción
flutter build apk --release
```
