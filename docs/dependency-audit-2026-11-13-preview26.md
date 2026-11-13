# Preview 2.6.0-beta.1 upstream review — 13 November 2026

Fresh review of Flutter/Dart, Gradle/AGP/Kotlin/Android tools, hosted Pub locks, ONNX Runtime, Stockfish, Maia and pinned chess/UI sources. Compact metadata, dated URLs, 63 exact-version Pub/Maven OSV queries and package-specific decisions are retained in release evidence. OSV returned no findings; it does not cover every build-tool advisory.

## Required update

Gradle 9.8.1 is affected by the 10 November catalog/daemon-registry advisories. Upgrade to 9.9.1 using the official distribution checksum and an updated offline pin gate. [Review](gradle-security-2026-11-13.md); [Stable companion #73](https://github.com/Dash1971/maia-chess-android/pull/73). Both repositories receive identical pin/gate changes and tests. No Stable app promotion/publication follows from this change.

## Retained pins and deferrals

Flutter 3.47.8 / Dart 3.13.7 already fix [GHSA-frr6-h895-5pxp](https://github.com/dart-lang/sdk/security/advisories/GHSA-frr6-h895-5pxp). Flutter stable now advertises 3.50; defer the feature/SDK and Material migration to separate compatibility qualification. Keep the established reproducible SDK revision and Android toolchain. AGP/Kotlin/tool updates likewise need independent Gradle/Flutter/native-plugin qualification; no additional applicable published advisory was found in this review.

ONNX Runtime 1.30.1 includes malformed-graph validation/memory fixes. This app accepts no external ONNX graph: Maia and diagram models are trusted pinned APK assets with checked hashes; diagram input is a bounded fixed-shape finite tensor. Keep 1.24.3 for this candidate rather than mix an unqualified runtime/ABI change with image import. Reassess if graph provenance or model-loading scope changes. [Upstream release](https://github.com/microsoft/onnxruntime/releases/tag/v1.30.1).

Stockfish 19/dev sources and current Maia upstream were checked. Retain locked multistockfish 0.6.1/light 0.1.0 and verified 79M/5M models; a new engine/model requires separate inference/strength and reproduction qualification. The added diagram model matches pinned CrispChess revision, MIT provenance, 835655 bytes and SHA-256 2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47.

Nineteen available Pub updates were reviewed from fresh hash-verified package archives; all are deferred with package-specific reasons in evidence. In particular dartchess 0.15 changes PGN command parsing, shared_preferences_android 2.5 migrates to JNI/Pigeon, and newer Flutter UI packages require a coordinated SDK migration. Existing preferences, PGN and native runtime behavior remain qualified with their locks.

No general translation editorial review was repeated. Current catalog/terminology/layout contracts cover the new and existing UI.
