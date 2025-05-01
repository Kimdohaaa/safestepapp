import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// 버전 변수는 gradle.properties에서 관리하는 게 가장 안전함
// gradle.properties에서 다음과 같이 정의할 수 있습니다:
// appCompatVersion=1.4.2
// playServicesLocationVersion=21.3.0

allprojects {
    repositories {
        google() // Google repository 추가
        mavenCentral()

        // [required] flutter_background_geolocation
        maven {
            url = project(":flutter_background_geolocation").projectDir.resolve("libs").toURI()
        }

        // Huawei 지원 (필요할 경우)
        maven {
            url = uri("https://developer.huawei.com/repo/")
        }

        // [required] background_fetch
        maven {
            url = project(":background_fetch").projectDir.resolve("libs").toURI()
        }

        // 추가 의존성 (예: JitPack)
        maven {
            url = uri("https://jitpack.io")
        }
    }
}

// Flutter의 빌드 디렉토리를 루트 바깥으로 변경 (필요 없으면 생략 가능)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// 하위 모듈들의 빌드 디렉토리 설정
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 하위 프로젝트 평가 우선순위 설정
subprojects {
    project.evaluationDependsOn(":app")
}

// clean 명령어 정의
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

buildscript {
    repositories {
        google() // Google repository 추가
        mavenCentral()
    }
    dependencies {
        // Firebase Google Services 플러그인 의존성 추가
        classpath("com.google.gms:google-services:4.4.2")
    }
}
