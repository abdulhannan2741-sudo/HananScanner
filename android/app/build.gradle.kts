plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle plugin must be applied after Android & Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hanan.scanner"
    compileSdk = 34
    ndkVersion = "25.2.9519653"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.hanan.scanner"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            // Populate from android/key.properties (see README). Falls back to debug
            // signing if key.properties is not present so `flutter build appbundle`
            // still works out of the box for testing.
            val keyProps = rootProject.file("key.properties")
            if (keyProps.exists()) {
                val props = java.util.Properties()
                keyProps.inputStream().use { props.load(it) }
                keyAlias = props.getProperty("keyAlias")
                keyPassword = props.getProperty("keyPassword")
                storeFile = file(props.getProperty("storeFile"))
                storePassword = props.getProperty("storePassword")
            } else {
                keyAlias = "androiddebugkey"
                keyPassword = "android"
                storeFile = rootProject.file("app/debug.keystore")
                storePassword = "android"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        debug {
            isMinifyEnabled = false
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:23.2.0")
}
