# Dependency and advisory audit — 2026-09-29

## Subject

- Lane: qualified Preview hardening, before any APK build
- Repository: `Dash1971/maia-chess-android-preview`
- Base: `v2.2.0-beta.3` (`6b39b553bbcf4c3de40fd7a3bd1161807e236cde`)
- Audited implementation head: `2d05fbe` (this report is a documentation-only follow-up)
- Package: `com.dash1971.maia_chess.preview`
- Intended artifact: universal Android Preview APK; no signing or publication authorized by this audit

The dependency-bearing inputs were hashed after the hardening changes:

| Input | SHA-256 |
|---|---|
| `pubspec.yaml` | `6d094d65e5dbe6e62d01f37eeee4eeecfec15b0c47190d2dc370d438a7aa6749` |
| `pubspec.lock` | `987fea9a845ac33905a08a3e3dbf5d3f2885eac28d66a22ecaa0c2e6cb2b18aa` |
| `.fvmrc` | `7497dd33ac327599473c33e21cd57b25a1c0437809fe28dfa4a20a24aea2a5ec` |
| `android/settings.gradle.kts` | `4a8acd3d36d571e73d58a00c5079133dc16c6d82f476282f6c1687c064dfb758` |
| `android/gradle/wrapper/gradle-wrapper.properties` | `b690d26223576fe4e63889fad9a00df81945cb870b9476cc5a563152a1a88a74` |
| `android/app/build.gradle.kts` | `51f3f5048fa2e7e3c71765a37b0fcbe8a5a63bbec895e1ec0037dfc8daf5bdea` |
| `.github/workflows/checks.yml` | `b9d003b5b6e97b8262d943c60c0ab11c9d4d120c44771a3c0fba6f872f6f79a5` |
| `tool/prepare_reproducible_flutter_sdk.py` | `84dfd7d06e44adcab79519bf37e7a7b9f10a2f042c76dc779321e0c09874f036` |

## Decisions

| Component | Audited pin | Candidate | Evidence and risk | F-Droid / reproducibility | Decision |
|---|---:|---:|---|---|---|
| Kotlin Gradle Plugin | 2.4.0 plus plugin-private 2.1.0 | 2.4.20 | Earlier pins are affected by [CVE-2026-53914](https://github.com/advisories/GHSA-r937-wjx7-w2jp). Kotlin 2.4.20 contains the fix and supports the retained Gradle line. | Open-source Maven component; no proprietary service or opaque binary added. | **Upgrade completed:** root pin is 2.4.20 and the plugin-private pin was eliminated. |
| `sound_effect` | 0.2.0 | app-owned bridge | No fixed package release exists; the plugin carried its own obsolete Kotlin/AGP buildscript. | Replaced with reviewed source using Android `SoundPool`; this reduces F-Droid scanner and source-provenance complexity. | **Replace completed.** |
| Flutter / Dart | 3.47.1 / 3.13.1 | 3.47.5 / 3.13.4 | Flutter 3.47.2 updated libpng for security fixes; the selected patch release includes that fix. See the [Flutter hotfix changelog](https://github.com/flutter/flutter/blob/master/CHANGELOG.md) and [upstream security issue](https://github.com/flutter/flutter/issues/190987). | Exact Flutter tag and commit are pinned. The guarded deterministic-asset patch still applies to the exact source and the lockfile is unchanged. | **Upgrade completed.** |
| GitHub Actions | checkout v4, setup-java v4, upload-artifact v4 | checkout 7.0.1, setup-java 6.0.1, upload-artifact 7.0.1 | Earlier majors use the retired Node 20 action runtime. Current releases use Node 24. GitHub recommends immutable full-SHA pinning in its [Actions security guidance](https://docs.github.com/en/code-security/tutorials/secure-your-organization/protect-against-threats). | CI-only; no F-Droid recipe or APK payload change. Full commit SHAs prevent mutable tag drift. | **Upgrade completed.** |
| Multistockfish wrapper | 0.5.0 | unreleased 0.6.0 | Upstream main documents restart-race, blocking-write, descriptor-leak, stale-pipe, and closed-output fixes in its [changelog](https://github.com/lichess-org/dart-multistockfish/blob/main/pkgs/multistockfish/CHANGELOG.md). The coherent wrapper release is not published. | Retaining the locked published source is more reviewable than mixing unpublished wrapper code with newer native transitives. | **Retain temporarily; blocked from partial override.** Reassess when a coherent release or reviewed immutable source commit is available. |
| ONNX Runtime Android | 1.24.3 | 1.30.0 | No applicable advisory was found for the exact current Maven artifact. Version 1.30.0 contains broad input-validation, allocation, model-loading, lifetime, and dependency hardening in the [official release notes](https://github.com/microsoft/onnxruntime/releases/tag/v1.30.0). | Both are open-source Maven artifacts, but changing this native runtime can alter ABI payloads, model behavior, R8/JNI reachability, memory, and reproducibility. | **Retain for this slice; qualified Preview experiment required separately.** |
| Android build matrix | AGP 9.1.0, Gradle 9.3.1, JDK 17 | AGP 9.4 with Gradle 9.6/9.7 | No unresolved advisory requires a coupled jump. A broad matrix change would multiply release risk. See [AGP compatibility notes](https://developer.android.com/build/releases/agp-9-4-0-release-notes) and [Kotlin 2.4.20 compatibility](https://kotlinlang.org/docs/whatsnew2420.html). | Current matrix remains source-buildable. Evaluate a future matrix change independently and update the F-Droid recipe/toolchain together. | **Retain.** |
| Ordinary Dart/Flutter packages | exact `pubspec.lock` graph | available patches/majors | No applicable material advisory or required bug fix was identified in this audit. Newer is not itself a reason to change a release graph. | Lockfile remains unchanged, preserving F-Droid resolution and reproducibility. | **Retain.** |

## Validation completed before this report

- `flutter pub get --enforce-lockfile` with Flutter 3.47.5: passed; lockfile unchanged.
- Flutter analyzer: passed.
- 372 Flutter tests: passed.
- 31 repository tooling/contract tests: passed.
- Android Dev Kotlin compilation with JDK 17, Flutter 3.47.5, and Kotlin 2.4.20: passed.
- Guarded Flutter reproducibility patch applied to exact revision `6a19cca56475dbfba1478ee68d7bd0c2ef891da1`.
- No proprietary SDK, remote service, opaque replacement binary, Git dependency, or undeclared build-time network fetch was introduced.

## F-Droid impact

The proposed source remains compatible with the existing F-Droid model: build from a tagged source tree, resolve the locked Pub/Maven graph, compile native Stockfish sources locally, verify the LFS model, and compare the developer APK through `Binaries`. Before Stable 2.3, its recipe must update the exact Flutter revision and version metadata, then repeat the independent reproducible build and signing-key continuity checks. Automatic tag-based update discovery is preserved.

## Kotlin included-build qualification (follow-up review)

The root app pin is 2.4.20, but it does not override Flutter's independent
included Gradle build. At the pinned Flutter 3.47.5 revision, that build declares
Kotlin JVM 2.2.20 and resolves Kotlin Gradle Plugin **2.2.21** through Gradle's
`kotlin-dsl` plugin. This was verified with `android/gradlew
:gradle:buildEnvironment`; it is a retained upstream build dependency, not a
claim that every Kotlin component has been upgraded to 2.4.20.

The [upstream advisory fix](https://github.com/JetBrains/kotlin/commit/bf51df6)
filters deserialization of KAPT incremental caches. No KAPT use was found in
the inspected app or Flutter included build. This review did not demonstrate
an exploitable cache path. Keep build caches trusted and reassess applicability
if KAPT or cache-sharing configuration changes; do not silently force an
untested SDK build-plugin override. The original audit hashes and validation
above describe PR #48's inputs, not subsequent runtime changes.

## Gate result

**DEPENDENCY AUDIT PASSED** for the exact dependency-bearing inputs listed above. Any dependency, toolchain, workflow-action, native-source, model, patch, or lockfile change invalidates this result and requires a fresh audit before compilation.

## 2026-09-30 Preview release-gate addendum

The beta.4 release gate invalidated the earlier temporary Multistockfish
retention decision. The full Android integration suite reproduced a native
`SIGSEGV` in `libmultistockfish_sf16.so` while an engine was restarting after
a startup timeout. The tombstone resolves into the old native library's engine
thread; this is the same failure class described by upstream 0.6.0: a
replacement engine could run over process-global state while its predecessor
was still tearing down.

Upstream published a coherent wrapper and native set during this qualification:

- `multistockfish 0.6.1`
- `multistockfish_chess 0.6.0`
- `multistockfish_light 0.1.0`
- `multistockfish_variant 0.4.0`

The app now uses the intended per-engine handle API rather than the deprecated
process-wide singleton. A handle is disposed before another engine of the same
flavor can be created. Focused failure/restart tests and the Android crash
reproducer pass with the new graph.

The default engine changes from Stockfish 16 with a 38 MB net to Stockfish 19
with a roughly 1 MB embedded net. The light package's exact CMake source
downloads that net during compilation from Stockfish's official test service
and pins SHA-256
`61e7af4bb97d51eeeb25d322916f86513b5cd3a827ce189c98c6e31946f99e5b`.
The existing `tool/prepare_reproducible_stockfish.py` entry point now guards
the new exact package/version/source shape, verifies the same hash, records the
download status and fails the build on any fetch or verification error. The
F-Droid recipe already calls this stable helper name, so tag-based automatic
updates do not require a metadata ticket or manual recipe change.

The four exact Pub packages returned no OSV advisory on 2026-09-30. Their
Android manifests add no permission, and the release APK verifier now requires
the new `libmultistockfish_light.so` payload for every ABI. No Git dependency,
prebuilt opaque library, proprietary SDK, runtime network path or Internet
permission is introduced. The dependency and lockfile change requires the full
source, native, reproducibility and privacy gates to be repeated before beta.4
can be signed.
