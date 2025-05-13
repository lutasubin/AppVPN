# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/huangyifei/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Keep all VPN classes
-keep class de.blinkt.openvpn.** { *; }
-keep class org.spongycastle.** { *; }
-keep class net.openvpn.** { *; }

# Keep JNI methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep chart library
-keep class com.github.mikephil.charting.** { *; }
-dontwarn io.realm.**

# Keep model classes
-keep class **.model.** { *; }
-keep class **.models.** { *; }

# OpenVPN specific
-dontwarn de.blinkt.openvpn.**