# Preview 2.6.0-beta.12 — 23 November 2026

[Published prerelease](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.12) · [PR #265](https://github.com/Dash1971/maia-chess-android-preview/pull/265) · [release #266](https://github.com/Dash1971/maia-chess-android-preview/pull/266)

Recent games → ⋮ → Import PGN saves all validated games, including a single game; Analysis file/paste opens only the first and points to Recent games. Android automatic file/share routing is retained. Home/background autosaves no longer create a second saved identity during the clear transition. Existing duplicate records are not removed.

## Exact-source qualification

- Source/tag: `3f2ceaa15dac260f9ca10ebbf90a38bb84fe4312` / `v2.6.0-beta.12`; code 2612, 79M, existing Preview package and signing identity.
- [CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/45097556742): 1,565 Flutter host tests, analysis/localization/native-policy/verification checks and Android build passed. Translation editorial review was not repeated.
- Canonical GitHub Linux and independent Linux unsigned SHA-256: `f407ad14d4abc4e49da995d9cba80cedb04e105d5bb80da547d3a236ce050980`.
- Signed APK SHA-256: `1359af3cd4eea4d801c6b8b4e9b4f69d1317baabdf04c99650800700855dce8e`; 455355432 bytes. Established certificate `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction used the actual independently built file and matched byte for byte.
- Model SHA-256: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Identity, artwork/notices, alignment, permitted ABIs, retired payloads and 79M-only APK contents passed.
- Full 16 core native checks, two additional real 79M feature checks, 3,000 oracle positions, 512 variation trees and 27 promotion regressions passed on exact source.
- Actual production-signed beta.11→beta.12 upgrade retained UID, settings, game and capture bytes/semantics. Real 79M history-off/on play passed. Three temporary-key fixture upgrades retained duplicate-takeback, incomplete and checkmate active/archive/restart semantics.
- Installed production APK: empty Recent menu/picker cancel, single/all-game import, within-file/existing duplicates, current-game preservation, invalid-later whole-import rollback, >5MiB provider bound, first-only Analysis file/paste (including invalid later game), native cold file and warm share, actual export/re-import, interrupted staging cleanup, 10,000 near 5 MiB games with all PGN hashes checked/atomic visibility/restart, and eight completed-game Home/background cycles passed. Deterministic host regression holds the Home transition at the reproduced race point. Emulator timing is observational.
- Shared tooling matches the Stable #82 counterpart; 107 Preview and 152 Stable Python checks passed. Existing main helpers match. New PGN manifest contract belongs with the already-ported routing behavior in #82; a test-only 2.5 main port would fail intentionally. Stable #83 merged into #82, not Stable main.

## Upstream review and diagnostics

The [fresh 23 November review](../dependency-audit-2026-11-23-preview26-beta12.md) records exact versions, 63 OSV lookups and 23 hash-verified Pub candidates with scoped update/deferral decisions. ONNX GitHub release/advisory feeds returned 404; official servicing/Maven and exact-version OSV were reviewed. Unavailable feed coverage is explicit.

A System UI ANR was caught by readiness before any native app build; normal Wait and recheck allowed the full native suite to run once. An initial one-second baseline-background assertion was too early. The fixture driver then force-stopped after the checkpoint changed but before restore-pending cleared; the candidate correctly opened safe Home. Diagnostics were retained. Bounded normal-lifecycle waits corrected the driver scheduling, followed by all affected fixture checks. During the near-limit collection, repeated accessibility polling briefly returned an empty tree while screenshots showed live progress. The same import was retained, all 10,000 PGN hashes and atomic commit were verified, and navigation waited for the Recent refresh before restart. The original file hash comparison for that large test covers restart; earlier interruption/export tests and host regressions independently cover existing-file preservation during imports. A 40-second restarted-list wait also timed out under host load averages of 39/77/62; a later fresh snapshot and final assertions verified the same restarted list without repeating restart/import. This is functional recovery evidence, not phone latency qualification. App source and recovery guards were unchanged; builds/native checks and the large import were not repeated for driver corrections.

## Public verification and cleanup

All three initial public assets were downloaded and hash/digest checked. The public APK matched the qualified signer, identity, model, payload and reconstructed unsigned source. Public verification and cleanup receipts are separate release assets and were read back. Immediate checked cleanup on all participating hosts preceded documentation CI.

- mac: 82.36→91.60 GiB free; task scratch, generated outputs and qualified source retired.
- linux: 22.61→27.38 GiB free; task scratch, generated outputs and qualified source retired.
- signing: 15.58→16.53 GiB free; task scratch, generated outputs and qualified source retired.

Task APKs, source model copies, venv, emulator, Linux container and build/signing clones were removed. Shared SDK/JDK/Flutter/Gradle/pub/LFS caches, keys and other active work remain. Compact final evidence is verified in the Mac mini archive at task completion. Stable 2.5.1/Dev alpha.2 releases remain unchanged; Stable 2.6 qualification/promotion is separate. Grand Kingdom acceptance remains passed and Pegasus withdrawn.
