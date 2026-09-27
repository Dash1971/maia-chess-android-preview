import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

val stockfishProjects =
    setOf(
        "multistockfish_chess",
        "multistockfish_sf16",
        "multistockfish_variant",
    )
val nativeSourceDateEpoch =
    providers.gradleProperty("mobileMaiaSourceDateEpoch").orElse("unset")

subprojects {
    if (name in stockfishProjects) {
        plugins.withId("com.android.library") {
            extensions.configure<LibraryExtension> {
                defaultConfig {
                    externalNativeBuild {
                        cmake {
                            // Android's default linker build ID varies between
                            // otherwise identical native builds. The timestamp
                            // argument also makes a new release invalidate old
                            // CMake outputs that may contain __DATE__.
                            arguments +=
                                listOf(
                                    "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,--build-id=none",
                                    "-DCMAKE_CXX_FLAGS=-DMOBILE_MAIA_SOURCE_DATE_EPOCH=${nativeSourceDateEpoch.get()}",
                                )
                        }
                    }
                }
            }
        }
    }
}

subprojects {
    if (name == "sound_effect") {
        // sound_effect 0.2.0 pins compileSdk 35, while its current Android
        // lifecycle dependency requires API 36. This changes compilation
        // availability only; Mobile Maia's targetSdk and runtime behavior stay
        // unchanged.
        afterEvaluate {
            extensions.configure<LibraryExtension> {
                compileSdk = 36
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
