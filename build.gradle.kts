plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.agrigo_app"
    compileSdk = 35           // use explicit SDK version
    ndkVersion = "27.0.12077973"  // NDK version required by plugins

    defaultConfig {
        applicationId = "com.example.agrigo_app"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // Signing config for release build
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

 flutter {
    source = "../.."
}
