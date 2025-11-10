allprojects {
    repositories {
        google()
        mavenCentral()
        maven { setUrl("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { setUrl("https://djl-ai.s3.amazonaws.com/maven/") } // Added DJL Maven repository
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Force all plugins to compile against SDK 36
    afterEvaluate {
        project.extensions.findByName("android")?.apply {
            val compileSdkProperty = javaClass.getMethod("getCompileSdk")
            val currentSdk = compileSdkProperty.invoke(this) as? Int
            
            if (currentSdk != null && currentSdk < 36) {
                try {
                    javaClass.getMethod("compileSdk", Int::class.javaPrimitiveType).invoke(this, 36)
                } catch (e: NoSuchMethodException) {
                    // Try property setter
                    javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType).invoke(this, 36)
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
