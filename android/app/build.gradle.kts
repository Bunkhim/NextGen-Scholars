// File: android/app/build.gradle.kts

import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun keystoreValue(key: String): String? {
    val fromFile = keystoreProperties.getProperty(key)
    if (!fromFile.isNullOrBlank()) return fromFile
    val envKey = "KEYSTORE_" + key.replace(Regex("([a-z])([A-Z])"), "$1_$2").uppercase()
    return System.getenv(envKey)
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

android {
    namespace = "com.example.scholarship_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }



    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.scholarship_app"   // នេះហើយជា package name
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreValue("storeFile")
            val storePasswordValue = keystoreValue("storePassword")
            val keyAliasValue = keystoreValue("keyAlias")
            val keyPasswordValue = keystoreValue("keyPassword")

            require(!storeFilePath.isNullOrBlank()) {
                "Release signing: keystore.properties missing or storeFile unset. " +
                    "Copy android/keystore.properties.example to android/keystore.properties or set KEYSTORE_* env vars."
            }
            require(!storePasswordValue.isNullOrBlank() && !keyAliasValue.isNullOrBlank() && !keyPasswordValue.isNullOrBlank()) {
                "Release signing: keystore credentials missing. Populate android/keystore.properties or set KEYSTORE_* env vars."
            }

            storeFile = file(storeFilePath)
            storePassword = storePasswordValue
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
}

flutter {
    source = "../.."
}
