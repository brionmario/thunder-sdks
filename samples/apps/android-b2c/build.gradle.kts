plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "io.thunder.sample.b2c"
    compileSdk = 34

    defaultConfig {
        applicationId = "io.thunder.sample.b2c"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        // Load Thunder config from local.properties or environment
        val baseUrl = project.findProperty("THUNDER_BASE_URL") as String? ?: ""
        val clientId = project.findProperty("THUNDER_CLIENT_ID") as String? ?: ""
        val appId = project.findProperty("THUNDER_APPLICATION_ID") as String? ?: ""
        buildConfigField("String", "THUNDER_BASE_URL", "\"$baseUrl\"")
        buildConfigField("String", "THUNDER_CLIENT_ID", "\"$clientId\"")
        buildConfigField("String", "THUNDER_APPLICATION_ID", "\"$appId\"")
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation(project(":compose"))

    val composeBom = platform("androidx.compose:compose-bom:2024.02.00")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")
}
