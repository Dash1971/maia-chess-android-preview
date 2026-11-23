# Preview beta.13 upstream review — 23 November 2026

Fresh upstream release/advisory requests,63 exact-version hosted Pub/direct ONNX/AGP/Kotlin OSV queries and23 hash-verified Pub update archives were reviewed for PGN analysis persistence, restoration and export stripping. No applicable new finding or required pin change was identified. Source responses and package hashes match the earlier same-day review; every deferral was reassessed for this release, not carried forward as an old pass.

Retain Gradle9.9.2 with its official distribution checksum, Flutter3.47.8/Dart3.13.7 and the guarded reproducibility backport. The reviewed Gradle November advisory ranges and Dart TLS advisory are patched by these pins. Flutter3.50.1/Dart3.14.1 and Kotlin2.4.21 do not require a compiler/toolchain migration for this feature. Retain AGP9.1.0, Kotlin2.4.20 and existing Android tools.

Keep pinned dartchess/chessground, shared preferences and Stockfish wrappers while qualifying portable PGN annotations and existing-record persistence. Available parser, FFI and storage migrations need separate compatibility and reproduction checks. Stockfish19 remains the pinned engine; the November22 development build is a prerelease. Maia/model source review does not require replacing Preview's79M model. Detailed per-package deferrals and fresh source dates/hashes are retained in release evidence.

## ONNX feed limitation

GitHub ONNX release/advisory endpoints again returned404. An unavailable feed is not an empty advisory list. Fresh [official servicing documentation](https://onnxruntime.ai/docs/reference/releases-servicing.html), [Android Maven metadata](https://repo.maven.apache.org/maven2/com/microsoft/onnxruntime/onnxruntime-android/maven-metadata.xml) and exact CPU1.24.3 OSV were reviewed; retain the pinned trusted models and CPU configuration. No external graphs or GPU plugins are enabled.

Primary sources: [Flutter](https://github.com/flutter/flutter/blob/stable/CHANGELOG.md), [Dart](https://github.com/dart-lang/sdk/blob/stable/CHANGELOG.md), [Gradle9.9.2](https://docs.gradle.org/9.9.2/release-notes.html), [Gradle advisories](https://github.com/gradle/gradle/security/advisories), [Kotlin](https://github.com/JetBrains/kotlin/releases), [Android tools](https://developer.android.com/tools/releases/platform-tools), [Stockfish](https://github.com/official-stockfish/Stockfish/releases), [Maia](https://github.com/CSSLab/maia3).

Ordinary localization/terminology and new-feature layout checks passed; the completed editorial translation review was not repeated.
