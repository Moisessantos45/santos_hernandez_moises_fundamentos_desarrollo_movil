# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Mantener entrypoints de JNI y Flutter
-keepclasseswithmembers class * {
    native <methods>;
}

# Flutter embedding
-keep class io.flutter.embedding.** { *; }

# No advertir sobre clases opcionales
-dontwarn io.flutter.embedding.**
-dontwarn javax.annotation.**
