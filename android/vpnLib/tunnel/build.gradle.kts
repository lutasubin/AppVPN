@file:Suppress("UnstableApiUsage")

import org.gradle.api.tasks.testing.logging.TestLogEvent

val pkg = "com.wireguard.android"

plugins {
    id("com.android.library")
    id("maven-publish")
    id("signing")
}

android {
    compileSdk = 36
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    namespace = "${pkg}.tunnel"
    defaultConfig {
        minSdk = 21
    }
    testOptions.unitTests.all {
        it.testLogging { events(TestLogEvent.PASSED, TestLogEvent.SKIPPED, TestLogEvent.FAILED) }
    }
    lint {
        disable += "LongLogTag"
        disable += "NewApi"
    }
    publishing {
        singleVariant("release") {
            withJavadocJar()
            withSourcesJar()
        }
    }
}

dependencies {
    implementation("androidx.annotation:annotation:1.6.0")
    implementation("androidx.collection:collection:1.2.0")
    compileOnly("com.google.code.findbugs:jsr305:3.0.2")
    testImplementation("junit:junit:4.13.2")
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = pkg
            artifactId = "tunnel"
            version = "1.0.0"
            afterEvaluate {
                from(components["release"])
            }
            pom {
                name = "WireGuard Tunnel Library"
                description = "Embeddable tunnel library for WireGuard for Android"
                url = "https://www.wireguard.com/"

                licenses {
                    license {
                        name = "The Apache Software License, Version 2.0"
                        url = "http://www.apache.org/licenses/LICENSE-2.0.txt"
                        distribution = "repo"
                    }
                }
                scm {
                    connection = "scm:git:https://git.zx2c4.com/wireguard-android"
                    developerConnection = "scm:git:https://git.zx2c4.com/wireguard-android"
                    url = "https://git.zx2c4.com/wireguard-android"
                }
                developers {
                    organization {
                        name = "WireGuard"
                        url = "https://www.wireguard.com/"
                    }
                    developer {
                        name = "WireGuard"
                        email = "team@wireguard.com"
                    }
                }
            }
        }
    }
    repositories {
        maven {
            name = "sonatype"
            url = uri("https://oss.sonatype.org/service/local/staging/deploy/maven2/")
            credentials {
                username = providers.environmentVariable("SONATYPE_USER").orNull
                password = providers.environmentVariable("SONATYPE_PASSWORD").orNull
            }
        }
    }
}

signing {
    useGpgCmd()
    sign(publishing.publications)
}
