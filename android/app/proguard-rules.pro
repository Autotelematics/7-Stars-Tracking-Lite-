# Flutter related
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase messaging - avoid unresolved class errors
-keep class com.google.firebase.messaging.** { *; }

# Google Maps (if used)
-keep class com.google.android.gms.maps.** { *; }

# Play Core library for deferred components & split install
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Retain annotations
-keepattributes *Annotation*

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
