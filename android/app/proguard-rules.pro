# Keep annotation classes with default constructor
-keep class android.support.annotation.Keep { void <init>(); }

# For AppCompatViewInflater
-keep class androidx.appcompat.app.AppCompatViewInflater { void <init>(); }

# For Google Play Services
-keep class com.google.android.gms.common.internal.ReflectedParcelable { void <init>(); }
-keep,allowshrinking class * implements com.google.android.gms.common.internal.ReflectedParcelable { void <init>(); }

# For annotations
-keep @interface android.support.annotation.Keep { void <init>(); }
-keep @interface androidx.annotation.Keep { void <init>(); }

# Firebase components
-keep class * implements com.google.firebase.components.ComponentRegistrar { void <init>(); }
-keep,allowshrinking interface com.google.firebase.components.ComponentRegistrar

# OkHttp
-keep class okhttp3.internal.publicsuffix.PublicSuffixDatabase { void <init>(); }

# Suppress R8 warnings for missing optional dependencies used by OkHttp
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE
