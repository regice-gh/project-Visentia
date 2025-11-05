plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.eindopdrachtmad"
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
        applicationId = "com.example.eindopdrachtmad"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
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
                "lib/arm64-v8a/libtokenizers.so",
                "lib/arm64-v8a/libjnidispatch.so",
                "lib/arm64-v8a/libonnxruntime4j_jni.so"
            )
        }
        // Ensure Android native libraries are included
        // Assuming ONNX Runtime's native lib
    }
}

dependencies {
    implementation("com.microsoft.onnxruntime:onnxruntime-android:1.17.3")
    implementation("ai.djl.huggingface:tokenizers:0.26.0") // Using 0.26.0 directly
    // Removed DJL BOM and djl-android dependency to simplify and avoid conflicts
}

flutter {
    source = "../.."
}
