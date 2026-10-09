# Guía de Optimizaciones para Flutter en Android — Maply

Esta guía documenta todas las optimizaciones de rendimiento, consumo de memoria, tiempos de compilación, tamaño de binarios y buenas prácticas aplicadas en el proyecto **Maply**.

---

## 1. Rendimiento y Memoria de Gradle (`android/gradle.properties`)

La configuración del archivo `android/gradle.properties` influye directamente en la velocidad del ciclo de desarrollo y en la estabilidad del sistema (evitando congelamientos por saturación de RAM).

```properties
# 1. Control de Memoria JVM para Gradle
org.gradle.jvmargs=-Xmx3072M -XX:MaxMetaspaceSize=1024M -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError

# 2. Aceleración de Compilación y Caché
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.daemon=true
org.gradle.vfs.watch=true
kotlin.daemon.jvmargs=-Xmx1536M

# 3. Optimizaciones de Android y R8
android.useAndroidX=true
android.enableJetifier=true
android.nonTransitiveRClass=true
android.enableR8.fullMode=true

# 4. Compatibilidad de Migración Flutter
android.builtInKotlin=false
android.newDsl=false
```

### Detalle de cada parámetro:

| Parámetro | Valor Configurado | Beneficio |
| :--- | :--- | :--- |
| **`org.gradle.jvmargs`** | `-Xmx3072M -XX:MaxMetaspaceSize=1024M` | Reduce el consumo desmedido de memoria de la JVM a 3 GB de Heap y 1 GB de Metaspace, previniendo saturación de memoria RAM del sistema operativo. |
| **`org.gradle.parallel`** | `true` | Permite a Gradle compilar proyectos y tareas independientes de forma simultánea aprovechando los múltiples núcleos de la CPU. |
| **`org.gradle.caching`** | `true` | Reutiliza salidas de compilaciones anteriores en lugar de recalcular tareas que no han sufrido cambios en su código fuente. |
| **`org.gradle.daemon`** | `true` | Mantiene caliente el proceso daemon de Gradle en segundo plano, acelerando las ejecuciones consecutivas de `flutter run` y `flutter build`. |
| **`org.gradle.vfs.watch`** | `true` | Monitorea cambios en el sistema de archivos en tiempo real para evitar reescanear todo el árbol de directorios en cada build. |
| **`kotlin.daemon.jvmargs`** | `-Xmx1536M` | Limita el consumo de memoria del daemon de compilación de Kotlin a un máximo de 1.5 GB. |
| **`android.nonTransitiveRClass`** | `true` | Evita la duplicación y propagación transitiva de clases de recursos (`R.java`), acelerando builds incrementales y reduciendo el tamaño del bytecode DEX. |
| **`android.enableR8.fullMode`** | `true` | Habilita el modo agresivo del optimizador R8, aplicando análisis profundo de código muerto (*dead-code elimination*) y optimizaciones avanzadas de llamadas (*inlining*). |

---

## 2. Optimización de Descargas de Gradle Wrapper (`android/gradle/wrapper/gradle-wrapper.properties`)

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-9.1.0-bin.zip
```

* **Distribución `-bin.zip` vs `-all.zip`**: 
  * `-all.zip` incluye documentación offline, código fuente completo de Gradle y ejemplos (~180 MB).
  * `-bin.zip` contiene únicamente los binarios requeridos para compilar (~50 MB).
  * **Beneficio**: Ahorro de más de 130 MB de descarga y menor tiempo de inicialización en entornos locales y pipelines CI/CD.

---

## 3. Compatibilidad de Java 17 y Modernización del Toolchain (`android/app/build.gradle.kts`)

```kotlin
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
```

* **Eliminación de Warnings Obsoletos**: Elimina avisos como `warning: [options] source value is obsolete`.
* **Soporte AGP 8.x+**: Alinea el proyecto con los estándares oficiales de Android Gradle Plugin 8.x que requieren JDK 17+.

---

## 4. Minificación, Reducción de Recursos y Exclusión de Tablas Pesadas (`android/app/build.gradle.kts`)

```kotlin
android {
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packaging {
        resources {
            excludes += "org/bouncycastle/pqc/**"
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE*"
            excludes += "META-INF/NOTICE*"
            excludes += "META-INF/*.kotlin_module"
        }
    }
}
```

* **`isMinifyEnabled = true`**: Ofusca y remueve código no utilizado en el proyecto y librerías mediante R8.
* **`isShrinkResources = true`**: Remueve recursos gráficos, strings y XMLs no referenciados, reduciendo drásticamente el peso final del APK.
* **`packaging.resources.excludes`**: Excluye tablas criptográficas innecesarias y metadatos de licencias que aumentan el peso del archivo `.apk`.

---

## 5. Aceleración Gráfica con Impeller (`android/app/src/main/AndroidManifest.xml`)

Dentro de la etiqueta `<application>`:

```xml
<application ...>
    <!-- Activar aceleración gráfica moderna de Impeller -->
    <meta-data
        android:name="io.flutter.embedding.android.EnableImpeller"
        android:value="true" />
</application>
```

* **Beneficio**: Utiliza el motor de renderizado moderno de Flutter (Impeller en Vulkan/OpenGL), eliminando los tirones (*jank*) causados por la compilación de sombreadores (*shader compilation*) en tiempo de ejecución.

---

## 6. Optimización de Red y Timeouts con Dio (`lib/config/api.dart`)

```dart
class Api {
  static final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );
}
```

* **Reutilización de Sockets TCP**: Una única instancia estática de Dio reutiliza conexiones HTTP en lugar de instanciar clientes nuevos por petición.
* **Control de Timeouts**: Previene que peticiones colgadas por mala cobertura de red consuman batería y sockets en segundo plano.

---

## 7. Buenas Prácticas de Rendimiento en UI y Memoria

### A. Decodificación Inteligente de Imágenes en Memoria
Al renderizar imágenes en `PlaceCard` o listas:
```dart
Image.network(
  place.imageUrl,
  cacheWidth: 300,
)
```
*Evita que imágenes de alta resolución ocupen megabytes innecesarios en la memoria RAM del dispositivo al decodificarse en su tamaño nativo.*

### B. Aislamiento de Animaciones con `RepaintBoundary`
En widgets con animaciones continuas (como loaders o indicadores de progreso):
```dart
RepaintBoundary(
  child: CircularProgressIndicator(),
)
```
*Evita que la GPU repinte el resto de la pantalla en cada cuadro de animación.*

### C. Gestión de Estado Granular con `ValueNotifier`
El uso de `ValueNotifier` y `ValueListenableBuilder` en lugar de llamadas globales a `setState()` garantiza que solo se reconstruyan los widgets que dependen del valor modificado, manteniendo una tasa de cuadros constante de 60/120 FPS.

---

## 8. Estrategias de Compilación para Producción

### A. Compilación Release con Ofuscación y Debug Symbols Separados (Recomendado)
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=./env.dev.json
```
* **`--obfuscate`**: Oculta nombres de clases y funciones en Dart para mayor seguridad.
* **`--split-debug-info`**: Extrae las tablas de símbolos de depuración fuera del APK y las almacena localmente, reduciendo el tamaño del binario.

### B. Distribución en Tiendas (Google Play Store)
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=./env.dev.json
```

### C. Generación de APKs Separados por Arquitectura (Distribución Directa)
```bash
flutter build apk --split-per-abi --dart-define-from-file=./env.dev.json
```
Genera un APK por cada arquitectura (`arm64-v8a`, `armeabi-v7a`, `x86_64`), reduciendo el tamaño promedio de ~50 MB a ~15–20 MB por archivo.
