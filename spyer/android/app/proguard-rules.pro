# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent R8 from removing Flutter JNI registration
-keepclassmembers class * {
    native <methods>;
}

# Preserve annotated elements
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
