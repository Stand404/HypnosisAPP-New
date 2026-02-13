import java.util.Properties  
  
// 1. 加载 
val localProps = Properties().apply {  
    val localFile = rootProject.file("local.properties")  
    if (localFile.exists()) load(localFile.inputStream())  
}
  
// 2. 读取变量（带空值保护）  
val releaseStoreFile: String     = localProps["RELEASE_STORE_FILE"] as? String ?: ""  
val releaseStorePassword: String = localProps["RELEASE_STORE_PASSWORD"] as? String ?: ""  
val releaseKeyAlias: String      = localProps["RELEASE_KEY_ALIAS"] as? String ?: ""  
val releaseKeyPassword: String   = localProps["RELEASE_KEY_PASSWORD"] as? String ?: ""

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hypnosis"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlin {
        jvmToolchain(21)  // 使用这个替换 kotlinOptions
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.stand.hypnosis_new"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(releaseStoreFile)
            storePassword = releaseStorePassword
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
        }
        release {
            // 临时禁用以解决编译问题
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
