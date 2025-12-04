pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Puedes dejar esta versión o usar una anterior si es necesario.
    id("com.android.application") version "8.11.1" apply false 
    
    // CAMBIO CLAVE: Versión de Kotlin requerida (1.9.24)
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

include(":app")