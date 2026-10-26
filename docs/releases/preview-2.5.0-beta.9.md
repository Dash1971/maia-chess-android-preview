# Preview 2.5.0-beta.9 qualification

Published [Preview 2.5.0-beta.9](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.9), code **2509**, from `3e71d02ee86d698e25b703de27d764aa5e87b589` through [release PR #196](https://github.com/Dash1971/maia-chess-android-preview/pull/196), after reviewed/merged [#195](https://github.com/Dash1971/maia-chess-android-preview/pull/195). The release merge tree equals the qualified source. Later documentation does not rebuild the APK.

Maia rating labels and score columns stay anchored through loading, missing results, changing percentages and terminal positions. Rating visibility uses reserved space rather than the current inference result; narrow screens and large text keep the compact presentation and accessible details.

Score calculations, inference, settings, saved formats, translations, models and dependencies are unchanged. The optional score remains off by default.

## Verification

- [Exact-source host/Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/40300330883): 1,255 host tests passed, three expected skips, plus static analysis, native policy, flavor, artwork/notice, localization and release-tool checks.
- Local review passed all **147** score/review tests, including 20 new regression cases across all ten languages, one/two engines, 560/390/320 logical widths and 100%/200% text. Controlled engine completion, navigation/loading, 100%, equal, missing and terminal states retain rating/score/title and board geometry. The regression is documented to fail on the old implementation with a 36 px label shift.
- Full exact-source ARM64 Android 16 Preview native suite: **16 passed** with real 79M references, Stockfish, storage/lifecycle. One additional native score test passed for the 79M outcome head, legacy move-only bridge, independent ratings, header geometry and native preference reload.
- Independent Ubuntu and GitHub unsigned APK SHA-256: `1153cd1c2eba53d2ca8409072fcb54dbed0af250c11da71a7c9fa564b3c02ab5`.
- Signed/public APK SHA-256: `d77bd5c56da53a238a2418f08baf2859d5a60d1c583945e9435599f71f05680c`. Established Preview signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction was byte-identical.
- Actual production-signed beta.8 → beta.9 upgrade preserved UID, preferences (including board designs/aids and score display), games and captures. Real 79M opening/middlegame play, 3,000 independent chess positions, 512 variation trees/four round trips and three upgrade/archive/restart fixtures passed.
- Actual signed APK score/title bounds remained fixed while navigating imported PGN positions and flipping the board: English/Japanese, one/two engines, 560/390/320 widths and 200% text. These real inference checks complement the controlled host transitions; they do not claim every loading frame was sampled on-device.
- Public APK, evidence bundle, checksums and receipt matched expected hashes/GitHub digests. Downloaded APK signer/model/artwork/package/version/payload verification passed; receipt was independently downloaded and compared.

[Fresh upstream review](../dependency-audit-2026-10-26-preview-beta9.md) records current sources and update/deferral decisions. Patched Flutter 3.47.8 / Dart 3.13.7 and Gradle 9.8.1 were retained; 63 exact hosted-Pub/direct-Maven OSV queries had no findings. Published package changelogs were also reviewed for 19 available Pub updates; package-specific deferrals are in the verification bundle. This UI-only change alters no shared tooling, so no Stable companion applies.

## Scope and cleanup

Stable and Dev releases are unchanged. Grand Kingdom/DGT remain Dev-only. Physical phone/Chessnut acceptance remains with testers. No translation editorial review was repeated; existing catalog/terminology contracts passed. Preview requires no screenshot maintenance. PR #195 has no linked open issue to close.

Immediately after public-download verification, checked cleanup removed task processes/emulator, bulk/APKs/archives, temporary environments, generated intermediates, completed source/model checkouts and the Linux container on all three hosts. Shared SDK/JDK/Flutter/Gradle/pub/LFS caches, signing keys and unrelated active work were preserved. Compact hashes, verification evidence and the inspected public pip CA bundle remain. README/channel documentation followed bulk cleanup in a source-only checkout.
