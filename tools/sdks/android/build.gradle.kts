plugins {
    id("com.android.library") version "8.2.2"
    id("org.jetbrains.kotlin.android") version "1.9.22"
    id("maven-publish")
}

group = "io.thunder"
version = "0.0.0"

android {
    namespace = "io.thunder.android"
    compileSdk = 34

    defaultConfig {
        minSdk = 26
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.google.code.gson:gson:2.10.1")

    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    testImplementation("io.mockk:mockk:1.13.9")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
}

publishing {
    publications {
        create<MavenPublication>("release") {
            groupId = "io.thunder"
            artifactId = "android"
            version = "0.0.0"
            afterEvaluate {
                from(components["release"])
            }
            pom {
                name.set("Thunder Android SDK")
                description.set("Android Platform SDK for Thunder identity management")
                url.set("https://github.com/asgardeo/thunder")
                licenses {
                    license {
                        name.set("Apache License 2.0")
                        url.set("https://www.apache.org/licenses/LICENSE-2.0")
                    }
                }
            }
        }
    }
}
