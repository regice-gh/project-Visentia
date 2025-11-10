plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.eindopdrachtmad"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.eindopdrachtmad"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.add("arm64-v8a") // Specify ABI for native libraries
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packagingOptions {
        resources.excludes.add("META-INF/maven/**")
        resources.excludes.add("META-INF/*.version")
        resources.excludes.add("META-INF/*.txt")
        jniLibs {
            pickFirsts += setOf(
                "lib/arm64-v8a/libonnxruntime4j_jni.so"
            )
        }
    }
}

dependencies {
    implementation("com.microsoft.onnxruntime:onnxruntime-android:1.17.3")
    // Removed DJL tokenizers - using custom SimpleTokenizer instead for Android compatibility
}

flutter {
    source = "../.."
}
