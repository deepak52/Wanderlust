plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
}

android {
    namespace = "com.example.wanderlust"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.example.wanderlust"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // ✅ Required for Java 8+ APIs
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug") // Keep this if you're not using a release keystore yet
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ Required for Java 17
    implementation("com.squareup.okhttp3:okhttp:4.10.0")
    // ✅ Use a consistent version for all Firebase dependencies (e.g. BOM)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    // Your Firebase libraries (these will use versions from BOM)
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-auth")
}
