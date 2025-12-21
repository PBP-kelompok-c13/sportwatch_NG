plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val splitPerAbi = project.hasProperty("split-per-abi")
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.sportwatch_ng"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.sportwatch_ng"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Priority 1: Environment Variables (Bitrise / GitHub Actions)
            val envStoreFile =
                System.getenv("BITRISEIO_ANDROID_KEYSTORE_URL")
                    ?: System.getenv("KEYSTORE_FILE")
            val envStorePassword =
                System.getenv("BITRISEIO_ANDROID_KEYSTORE_PASSWORD")
                    ?: System.getenv("KEYSTORE_PASSWORD")
            val envKeyAlias =
                System.getenv("BITRISEIO_ANDROID_KEYSTORE_ALIAS")
                    ?: System.getenv("KEY_ALIAS")
            val envKeyPassword =
                System.getenv("BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD")
                    ?: System.getenv("KEY_PASSWORD")

            if (envStoreFile != null) {
                storeFile = file(envStoreFile)
                storePassword = envStorePassword
                keyAlias = envKeyAlias
                keyPassword = envKeyPassword
            } else if (keystorePropertiesFile.exists()) {
                // Priority 2: Local Properties File (Local builds)
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }

    splits {
        abi {
            isEnable = splitPerAbi
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = !splitPerAbi
        }
    }
}

flutter {
    source = "../.."
}
