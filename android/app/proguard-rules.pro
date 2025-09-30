# Flutter/Dart specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Don't obfuscate any public static fields - they are probably used by class reflection
-keepclassmembers class * {
    public static <fields>;
}

# Don't obfuscate any public static methods - they are probably used by class reflection
-keepclassmembers class * {
    public static <methods>;
}

# Rules for Play Core library
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
