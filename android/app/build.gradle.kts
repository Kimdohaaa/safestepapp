import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Firebase Google Services 플러그인
}

android {
    namespace = "com.example.safestepapp"
    compileSdk = 35  // flutter.compileSdkVersion에 맞추거나 수정할 수 있음

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.safestepapp"
        minSdk = 24
        targetSdk = 35  // flutter.targetSdkVersion에 맞추거나 수정할 수 있음
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
    source = "../.."  // Flutter 프로젝트의 경로
}

// 버전 정보는 gradle.properties에서 불러오기
val appCompatVersion: String by project
val playServicesLocationVersion: String by project

dependencies {
    implementation("androidx.appcompat:appcompat:$appCompatVersion")
    implementation("com.google.android.gms:play-services-location:$playServicesLocationVersion")

    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
}
