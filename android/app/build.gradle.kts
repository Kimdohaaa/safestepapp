import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.safestepapp"
    compileSdk = 35  // 또는 flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.safestepapp"
        minSdk = 24
        targetSdk = 35  // 또는 flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
//           shrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}

// 버전 정보는 gradle.properties에서 불러오기
val appCompatVersion: String by project
val playServicesLocationVersion: String by project

dependencies {
    implementation("androidx.appcompat:appcompat:$appCompatVersion")
    implementation("com.google.android.gms:play-services-location:$playServicesLocationVersion")
}
