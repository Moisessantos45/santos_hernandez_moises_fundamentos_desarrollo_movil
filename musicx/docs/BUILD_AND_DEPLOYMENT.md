# Compilación, Despliegue y Optimizaciones

Guía para compilar, configurar y desplegar MusicX en entornos de desarrollo y producción.

---

## 1. Enlace de Descarga Directa

Puedes descargar el binario APK listo para instalar desde el siguiente enlace:

📦 **Descargar APK:** [https://zurl.mmabitec.uk/LawuIv](https://zurl.mmabitec.uk/LawuIv)

---

## 2. Variables de Entorno (`env.dev.json`)

Los datos sensibles como la URL de Supabase y la clave pública no se insertan en código duro, sino mediante el archivo `env.dev.json`:

```json
{
  "SUPABASE_URL": "https://<tu-proyecto>.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_<tu-clave>"
}
```

---

## 3. Comandos de Ejecución y Compilación

### Modo Desarrollo
```bash
flutter run --dart-define-from-file=./env.dev.json
```

### Compilación Release Optimizada (Recomendado)
```bash
flutter build apk --release --dart-define-from-file=./env.dev.json --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Compilación por Arquitectura (APKs reducidos ~15-20 MB)
```bash
flutter build apk --split-per-abi --dart-define-from-file=./env.dev.json
```

---

## 4. Optimizaciones Nativas Aplicadas

- **Gradle JVM**: Reducción de consumo de memoria a 3 GB de Heap y 1 GB de Metaspace.
- **R8 Full Mode**: Ofuscación y eliminación agresiva de código muerto (*dead-code elimination*).
- **ProGuard**: Reglas de compatibilidad para Supabase y Flutter deferred components.
- **Gradle Wrapper**: Uso de la distribución `-bin.zip` para ahorrar tiempo y ancho de banda.
- **Aceleración Gráfica**: Habilitada la renderización moderna con Impeller.
- **UI Flutter**: Aislamiento de animaciones con `RepaintBoundary` y decodificación limitada de imágenes en memoria con `cacheWidth: 800`.
