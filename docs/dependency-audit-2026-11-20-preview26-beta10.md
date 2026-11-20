# Preview beta.10 upstream review — 20 November 2026

Fresh release/security requests, official SDK/build-tool documentation and 23
hash-verified Pub update archives were reviewed for this release. All 63 exact
hosted-Pub and direct ONNX/AGP/Kotlin Maven OSV queries returned no findings.
The GitHub ONNX repository/advisory endpoints returned404 on repeated requests;
the coverage limit and primary-source fallback are recorded below.

## Applied build-security patch

Gradle9.9.1 is affected by four advisories published19November. Upgrade the
wrapper and offline security gate to official9.9.2, with the official distribution
SHA-256. The [security review](gradle-security-2026-11-20.md) records daemon
registry permissions, TestKit temporary directories, transitive snapshot
verification and SFTP host-key verification. Shared Linux/macOS build hosts make
the registry issue relevant. Java17 remains supported. Canonical and independent
Linux builds plus native qualification must pass before Preview publication.

[Stable companion #81](https://github.com/Dash1971/maia-chess-android/pull/81)
ports the same wrapper/gate/tests/review note. It is separate from this Preview
release and remains unmerged pending its own review. It supersedes the proposed
9.9.1 pin in pending #73. Stable/Dev app versions, features and releases are
unchanged. All four shared workspace helpers are identical;18 helper/security-pin
checks passed in each repository before CI.

## Reviewed deferrals

- Flutter3.50.1 fixes3.50 regressions in Android plugin configuration/asset
  packaging and platform tooling. Retain pinned Flutter3.47.8/Dart3.13.7 with its
  TLS security fix and guarded reproducibility backport. A framework migration
  needs separate compatibility/reproducibility qualification. Dart3.14.1's AOT
  pattern-switch compiler fix does not require a migration for these fixes.
- AGP9.5.1 is the current stable release;9.6.0-alpha04 is a prerelease. Retain
  reviewed AGP9.1.0/Kotlin2.4.20 while qualifying the Gradle security patch.
  Exact-version OSV queries are clear; no applicable advisory requires an AGP or
  Kotlin migration. Kotlin2.4.21/2.5RC remain separate compatibility work.
- Four new multistockfish wrapper/native-flavor updates introduce native-thread
  lifecycle/FFI changes and breaking APIs. Retain0.6.1 and its locked native
  flavors, including light0.1.0, with reviewed NNUE download/hash guards. Test
  threading, cancellation and reproducibility/cache-patch support separately.
- The other19 Pub current/latest versions and downloaded archive hashes match the
  preceding review. Each deferral was reassessed for these storage/lifecycle
  changes. In particular, shared_preferences_android2.5 migrates to Pigeon JNI;
  retain the tested2.4 backend during game-recovery qualification. Dartchess's PGN
  embedded-command storage migration remains separate work.
- Stockfish's latest development build and Maia's release/advisory records were
  reviewed; retain pinned engine/model graphs and existing numerical references.
  Stable Platform-Tools37.0.1 is retained over37.0.3 Canary after reviewing the
  full official revision article. Shared toolchains/caches are reused.

## ONNX Runtime availability and coverage

The official GitHub release/advisory APIs and advisory page returned404 after
repeat requests on20November. This is an unavailable feed, rather than evidence
of an empty current advisory list. The official servicing documentation and
Maven Central Android artifact metadata remain accessible. Central lists1.32.0
as latest, with metadata last updated13November. Retain Android CPU1.24.3 and
trusted pinned Maia graphs pending separate ABI/numerical qualification of a
runtime migration. The exact1.24.3 OSV query returned no finding. External ONNX
model import and CUDA/WebGPU plugins are unused. Compact evidence retains the
failed requests, accessible primary-source responses/hashes and this deferral;
no fresh GitHub advisory-clearance claim is made for the inaccessible feed.

Primary sources: [Flutter hotfixes](https://github.com/flutter/flutter/blob/stable/CHANGELOG.md),
[Dart changelog](https://github.com/dart-lang/sdk/blob/stable/CHANGELOG.md),
[AGP metadata](https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/maven-metadata.xml),
[Android tools](https://developer.android.com/tools/releases/platform-tools),
[ONNX servicing](https://onnxruntime.ai/docs/reference/releases-servicing.html),
[ONNX Android metadata](https://repo.maven.apache.org/maven2/com/microsoft/onnxruntime/onnxruntime-android/maven-metadata.xml).
Per-package changelogs, hashes and decisions are retained in compact release
verification. Ordinary localization/terminology checks remain required; the
completed editorial translation review is not repeated.
