pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false // mise à jour Kotlin
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")

// Configuration des dépôts pour tous les projets
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirection du dossier build vers ../../build
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Redirection des builds des sous-projets dans ce dossier
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Assure que l’évaluation de tous les sous-projets dépend de l’évaluation du module :app
subprojects {
    project.evaluationDependsOn(":app")
}

// Déclaration d’une tâche clean globale
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
