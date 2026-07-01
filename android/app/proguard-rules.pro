# Flutter embedding (from flutter_tools/gradle/flutter_proguard_rules.pro)
-dontwarn io.flutter.plugin.**
-dontwarn android.**

-if class * implements io.flutter.embedding.engine.plugins.FlutterPlugin
-keep,allowshrinking,allowobfuscation class <1>

# Prio native notification listener + platform bridge
-keep class com.prio.prio.** { *; }
-keep class * extends android.service.notification.NotificationListenerService { *; }

# MethodChannel / EventChannel handlers
-keep class io.flutter.plugin.common.** { *; }
