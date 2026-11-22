# Preview 2.6.0-beta.11 qualification and cleanup

Published 22 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.11), code 2611. PR #261 and release #262 are merged. Exact source `b3f87cf1f8273adb18a6954f875877de94a168e9` is preserved by the release tag; publication documentation does not rebuild the APK.

## Delivered behavior

PGN collections transfer into Recent games with matching 5 MiB import/export limits, duplicate detection across export/re-import, transactional saving and delayed progress feedback. Single-game PGNs still open for analysis. Android PGN content URIs use the native document bridge with Flutter generic deep-link routing disabled. Board messages are device-neutral; Grand Kingdom is supported with passed user acceptance, and Pegasus is withdrawn.

PGN transfers supported game content, not application settings or live clock/motor checkpoints. Stable 2.6 promotion remains separate. Earlier camera withdrawal, game recovery and same-page analysis resume remain intact.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/45022337783): 1,547 host tests passed; 0 skipped. Android passed.
- Canonical GitHub Linux and independent Linux APKs are byte-identical. Established Preview signer, identity/version, model/artwork/licences, native alignment, payload comparison and byte-identical signature reconstruction passed.
- Full ARM64 API36 real 79M native suite: 16 core tests plus score/continuation tests passed. Expanded checks cover 3,000 positions and 512 variation trees; 27 promotion regressions passed.
- Actual production-signed beta.10 upgrade preserved UID, games, settings and captures, including an explicitly saved timing-off choice. Real 79M play and three saved-game/archive/restart fixtures passed.
- Actual production APK checks exercise Android PGN collection sharing, document save/open and content-URI import, pasted collections, names/dates/annotations/setup, export/re-import duplicate avoidance, malformed/oversized rejection and retained export selection, interrupted staging/restart recovery and a 10,000-game near-5-MiB import with live progress and Recent games after restart. Emulator timings are observations, not phone performance promises.
- A synthetic retired-Pegasus save reopened on the phone, accepted a legal move and discarded stale board clock/pending movement. Compiled prototype markers and retired image-recognition payloads are absent. This adds no physical-board or firmware coverage; Grand Kingdom user acceptance is already passed.
- Shared helpers, Gradle gates and localization checker are identical across repositories. Twelve workspace, six security-pin and twelve localization-checker tests passed in each. [Stable companion #82](https://github.com/Dash1971/maia-chess-android/pull/82) remains open/unmerged; no Stable build/publication was authorized here. Prior [security #81](https://github.com/Dash1971/maia-chess-android/pull/81) is merged.
- The native PGN URI routing opt-out is also proposed in [Stable companion #83](https://github.com/Dash1971/maia-chess-android/pull/83), an unmerged draft with passing checks. An initial emulator run was interrupted by a System UI ANR; normal dismissal restored focus. A subsequent run passed 15 core checks but timed out loading sound clips under heavy host load. The final full unchanged-source run passed without relaxing timeouts; compact diagnostics from both failures are retained. Granted and ungranted content-URI behavior was checked on the production APK.
- Localization/terminology, static analysis, native board policy, all flavor policies and release verification tools passed. The completed editorial translation review was not repeated.
- APK UI qualification retained diagnostics for test-driver assumptions (an unexposed text-field accessibility node, a transient invalid snapshot and a missing screenshot-library dependency). The driver/environment were repaired and the affected checks passed on the same production APK; source and test acceptance limits were unchanged.
- Public APK/archive/checksums matched qualified bytes and GitHub digests; the published signer/model/payload checks and receipt readback passed.

Unsigned SHA-256: `12ea33532cd313f00f37470a609ed9405b68dc3be735e5125a64dada605b30f5`.
Signed APK SHA-256: `ddd4239028cbdddf5868934135034a4e39345cfd982da733ebe78ada9023a590`.
79M SHA-256: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
APK 455,289,896 bytes; beta.10 delta +32,768 bytes.

[Fresh upstream review](../dependency-audit-2026-11-22-preview26-beta11.md) records 63 clear exact-version OSV queries and 23 freshly hash-verified update archives with deferrals. Gradle 9.9.2 is retained. ONNX GitHub release/advisory endpoints returned 404 again; accessible official servicing/Maven metadata and exact-version OSV were reviewed, with that feed coverage limit explicitly retained.

## Cleanup and evidence

Immediately after verifying the actual public download, checked cleanup stopped task-owned processes and removed APK/archive/model copies, virtual environments, emulator data, the Linux container and task build checkouts on all hosts, before documentation CI. The temporary CI unsigned APK was deleted. Shared SDK/JDK/Flutter/Gradle/pub/LFS caches, signing keys and unrelated work are preserved.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 106.33 → 115.68 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta11/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta11/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta11/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta11/android/.gradle`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta11-results/bulk`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta11` |
| linux | 22.61 → 27.38 | `/srv/container-ssd/tmp/codex-preview26-beta11/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta11/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta11/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta11/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta11/bulk`; `/srv/container-ssd/tmp/codex-preview26-beta11/source` |
| signing | 18.34 → 19.28 | `/Users/openclaw/.cache/codex-maia-preview26-beta11/bulk`; `/Users/openclaw/.cache/codex-maia-preview26-beta11/source` |

The source-only documentation checkout is removed after push, before CI. Merged task branches are retired after ancestry/tag checks; unrelated active checkouts and the open Stable companion are retained. Release assets retain compact evidence. Final historical local evidence is moved to the verified Mac mini archive at task completion; no per-release model or APK archive is kept locally. Completed beta.10 evidence was also verified there and retired locally.

Preview #27 remains closed after passed Grand Kingdom acceptance. Stable #15 and #74 track Stable delivery and remain open pending promotion. Stable and Dev published releases are unchanged.
