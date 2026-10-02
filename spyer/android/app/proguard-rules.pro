# Ignorar advertencias de clases opcionales de Play Core en Flutter
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Reglas de ofuscación para Flutter y Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Mantener métodos nativos JNI para Flutter
-keepclassmembers class * {
    native <methods>;
}

# Preservar atributos de depuración y anotaciones
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
