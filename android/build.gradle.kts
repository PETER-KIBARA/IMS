allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// Safely inject fallback namespace for legacy dependencies without afterEvaluate
subprojects {
    plugins.withId("com.android.library") {
        val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android != null && android.namespace == null) {
            android.namespace = "com.legacy.${project.name.replace("-", "_")}"
        }
    }
    plugins.withId("com.android.application") {
        val android = extensions.findByType(com.android.build.gradle.AppExtension::class.java)
        if (android != null && android.namespace == null) {
            android.namespace = "com.legacy.${project.name.replace("-", "_")}"
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}