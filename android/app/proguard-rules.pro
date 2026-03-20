# ProGuard rules for Isar
-keep class io.isar.** { *; }
-keep class * implements io.isar.IsarObject { *; }
-keep class * implements io.isar.IsarCollection { *; }
-keep class * implements io.isar.IsarEmbedded { *; }

# Keep Flutter generic classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.util.PathUtils { *; }
-keep class io.flutter.repo.Service { *; }
-keep class io.flutter.embedding.engine.FlutterShellArgs { *; }
