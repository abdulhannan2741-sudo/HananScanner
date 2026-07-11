# Keep Flutter engine & plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Syncfusion PDF viewer
-keep class com.syncfusion.** { *; }

# Don't warn about missing classes from optional plugins
-dontwarn org.webrtc.**
-dontwarn android.media.**
