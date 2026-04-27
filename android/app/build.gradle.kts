plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.moodiesapp"
    compileSdk = 36

    // ✅ FIX 1 — NDK version mismatch.
    // All plugins (audioplayers, firebase, etc.) require 27.0.12077973.
    // Using flutter.ndkVersion resolved to 26.3.11579264 which caused the warning.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.moodies.parentchild"
        minSdk = 23
        targetSdk = 35
        versionCode = 2
        versionName = "1.0.2"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            ndk {
                debugSymbolLevel = "FULL"
            }
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/DEPENDENCIES"
            excludes += "/META-INF/NOTICE"
            excludes += "/META-INF/LICENSE"
            excludes += "/META-INF/LICENSE.txt"
            excludes += "/META-INF/NOTICE.txt"
            excludes += "/META-INF/ASL2.0"
        }
    }

    buildFeatures {
        viewBinding = true
        dataBinding = true
    }

    useLibrary("org.apache.http.legacy")
}

flutter {
    source = "../.."
}

// ✅ FIX 2 — DataBinding compilation failure.
//
// ROOT CAUSE: Your custom view classes (ColorPicker, ColorPickerSeekBar,
// EmptyRecyclerView, ImageButton_define, ColourImageView, etc.) live under
// src/main/kotlin/. Kotlin's compiler (compileDebugKotlin) compiles them
// fine, but Android's DataBinding code-generator then emits *Java* binding
// files (ViewAddwordsBinding.java, etc.) that import those same classes.
// Those Java files are compiled by compileDebugJavaWithJavac, whose classpath
// does NOT automatically include the Kotlin compiler's output directory in a
// Flutter project (because Flutter moves the build dir two levels up).
// Result: 67 "package does not exist / cannot find symbol" errors.
//
// FIX: After the project is evaluated, explicitly add the Kotlin compile
// output directory onto the Java compile task's classpath for every build
// variant, and make the Java task depend on the Kotlin task so ordering
// is always correct.
afterEvaluate {
    listOf("Debug", "Release", "Profile").forEach { variant ->
        val kotlinTaskName = "compile${variant}Kotlin"
        val javaTaskName   = "compile${variant}JavaWithJavac"

        val kotlinTask = tasks.findByName(kotlinTaskName)
                as? org.jetbrains.kotlin.gradle.tasks.KotlinCompile
        val javaTask = tasks.findByName(javaTaskName)
                as? JavaCompile

        if (kotlinTask != null && javaTask != null) {
            javaTask.dependsOn(kotlinTask)
            javaTask.classpath += files(kotlinTask.destinationDirectory)
        }
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.navigation.fragment.ktx)
    implementation(libs.androidx.navigation.ui.ktx)
    implementation(libs.androidx.swiperefreshlayout)
    implementation(libs.gson)
    implementation(libs.universal.image.loader)

    implementation(libs.photoview)
    implementation(libs.core.ktx)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)

    // Analytics (⚠️ keeping for compatibility)
    implementation(libs.analytics)

    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.6.0")
    implementation("com.squareup.retrofit2:converter-scalars:2.3.0")
    implementation("com.jakewharton.retrofit:retrofit2-rxjava2-adapter:1.0.0")

    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:3.12.13")

    // Glide
    implementation("com.github.bumptech.glide:glide:4.16.0")
    annotationProcessor("com.github.bumptech.glide:compiler:4.16.0")

    implementation(libs.recyclerview.animators)

    implementation("com.intuit.ssp:ssp-android:1.1.1")
    implementation("com.intuit.sdp:sdp-android:1.1.1")
}