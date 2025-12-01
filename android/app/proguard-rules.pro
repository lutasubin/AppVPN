# Keep VPN related classes
-keep class de.blinkt.openvpn.** { *; }
-keep class org.spongycastle.** { *; }
-keep class net.openvpn.** { *; }

# Keep JNI interface
-keepclasseswithmembernames class * {
    native <methods>;
}

# Giữ tất cả native libs
-keepattributes *Annotation*
-keep class com.Lutasubin.freeVpn.MainActivity { *; }

# Keep all model classes
-keep class com.Lutasubin.freeVpn.models.** { *; }
-keep class com.Lutasubin.freeVpn.services.** { *; }

# Keep OpenVPN related classes
-dontwarn de.blinkt.openvpn.**
-dontwarn org.spongycastle.**

# Don't warn about missing classes from OpenVPN libraries
-dontwarn javax.naming.**

# Keep VPN engine and related classes
-keep class com.Lutasubin.freeVpn.services.VpnEngine { *; }

# Keep services
-keep public class * extends android.app.Service

# Flutter plugins
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.LegacySharedPreferencesPlugin
-keep class io.flutter.plugins.sharedpreferences.** { *; } 