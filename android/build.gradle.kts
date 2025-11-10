// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        // Required for fetching the Google Services plugin and other Android dependencies
        google()
        mavenCentral()
    }
    dependencies {
        // 1. REQUIRED: The Android Gradle Plugin (AGP) for building the Android app
       
        
        // 3. REQUIRED for Firebase: The Google Services plugin classpath (version 4.4.1 from the exercise)
        classpath("com.google.gms:google-services:4.4.1") 
    }
}

// Define repositories for all modules (like the 'app' module)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Standard configuration for all subprojects
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}