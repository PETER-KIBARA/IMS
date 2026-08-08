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
subprojects {
    project.evaluationDependsOn(":app")
}

// Auto-inject missing namespace for legacy dependencies (like escposprinter)
subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            android.namespace = "com.legacy.${project.name.replace("-", "_")}"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}