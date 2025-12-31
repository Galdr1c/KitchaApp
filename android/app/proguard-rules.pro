# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# MCP & AI Model Classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Prevent obfuscation of Repository models for JSON serialization
-keep class * extends RecipeModel { *; }
-keep class * extends AnalysisModel { *; }
-keep class * extends FoodItem { *; }

# Sentry
-keep class io.sentry.** { *; }
-keep interface io.sentry.** { *; }

# Sqflite SQLCipher
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }
