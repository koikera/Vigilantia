// build.gradle.kts na raiz do projeto

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Kotlin Gradle Plugin (versão 2.1.0 para compatibilidade com libs novas)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // Plugin Google Services (para Firebase)
        classpath("com.google.gms:google-services:4.4.2")
    }
}

plugins {
    // Plugin do Google Services como plugin standalone (também aqui para segurança)
    id("com.google.gms.google-services") version "4.4.2" apply false

}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🛠️ Define pasta build customizada (opcional, mas você já está usando)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// 🧹 Tarefa clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
