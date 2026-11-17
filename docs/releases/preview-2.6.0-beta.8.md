# Preview 2.6.0-beta.8 qualification and cleanup

Published 17 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.8), code 2608.
PR #246 and release #247 are merged. Qualified source `16211fdf9b003c9fcd1ca8fdbcbadaaef5da9abc` is preserved
by the release tag; subsequent documentation does not rebuild the APK.

## Delivered behavior

Landscape Analysis coordinates an independently scrolling move window with the
opening/engine header. Swiping up expands moves; a downward drag within deep
moves restores engine output before returning the entire list to its beginning.
The header can collapse during navigation; this is not an always-visible-engine
layout. The large board, toolbar and normal-window navigation remain fixed.
Pinned tabs/overlap handling keep selected rows clear of the tab strip.

Holding Back reveals the first row and initial position without highlighting a
move before move 1; holding Forward selects/reveals the final move. Repeated
holds reveal the destination after manual browsing without restarting analysis.
These work directly in portrait and landscape, without a rotation workaround.
Graph-tab endpoint requests are honored on returning to Moves. Portrait reserves
a measured move-row height. Side-variation behavior remains supported; no new
preference, dependency or storage format is added.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/44061586139): 1,451 tests passed, 4 expected skips; Android passed.
- Canonical GitHub Linux and independent Linux unsigned APKs match byte for byte. Production signer continuity, identity/version, real 79M/artwork/licences, alignment and byte-identical signature reconstruction passed.
- Full ARM64 API36 real 79M native suite: 16 plus score/continuation tests passed. Expanded oracles: 3,000 positions and 512 variation trees/four round trips; 27 promotion regressions passed.
- 352 focused real-font checks, 72 score/variation checks, 30 default-font nested checks and 46 Analysis/adaptive/channel checks passed. Stable/unflavored exclusions each passed four tests plus one expected skip. Static analysis, ordinary catalogs and terminology contracts passed; translation editorial review was not repeated.
- Current Stable shared helpers/docs are identical; 12 helper tests passed per repository. No tooling port applies to this app UI change; Stable promotion remains separate.
- Actual production-signed beta.7 upgrade preserved UID, games/captures/settings including timing off. Real79M play and three game/archive/restart fixtures passed.
- Actual signed APK checks cover direct first/last holds without rotation, repeated endpoint holds after browsing away, endpoint single-tap stability, first-row/no-selection at the initial board, normal/large-text phone portrait/landscape and tablet profiles. A short downward swipe from deep landscape moves restores engine output while the list remains deep; FEN and board rectangle are preserved. Full real computer analysis, graph-tab endpoint requests, rotation and 480×260 short-window controls passed. Screenshots and source/APK-bound results are retained.
- Public APK, compact verification archive and checksums matched qualified bytes and GitHub digests. Public signer/model/payload checks and receipt readback passed. A separate cleanup report is attached.

Unsigned SHA-256: `28b140254301845a2fc7403e223e4e0e8a9d2e8949d6026f236fa183f569c657`.
Signed APK SHA-256: `d92ebb0231f0c905899e772dd164a9ba3fc344fb3d09661f95c27391aa7b531d`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev 5M and withdrawn diagram model are excluded.
APK 455,535,656 bytes; change from beta.7 +278,528 bytes.

[Fresh upstream review](../dependency-audit-2026-11-17-preview26-beta8.md) records
11 primary-source groups, 63 clear OSV queries and 19 fresh hash-verified Pub
update decisions. The complete Platform-Tools revision article was reviewed;
stable ADB 37.0.1 is retained over Canary 37.0.3. Recorded SDK/runtime/engine/package
deferrals were reassessed. No applicable finding required a pin change.

## Remaining acceptance and cleanup

Physical touch/tablet and actual OS split-screen acceptance under #29 remain
separate. These emulator checks do not establish reporter-device satisfaction.
Grand Kingdom remains experimental; its owner's historical capture symptoms
were attributed to hardware drift/calibration, with good operation reported.
DGT stays Dev-only; camera/image recognition remains withdrawn. Stable and Dev
app releases are unchanged.

Immediately after actual public-download verification, checked cleanup stopped
the owned emulator/container and removed task intermediates, APK/archive copies,
virtual environment, AVD and source/model copies on every host before docs CI.
The task's verified idle Gradle daemon was stopped after native checks. The
owned temporary CI unsigned APK artifact was removed; compact CI verification,
logs and source/model/APK hashes remain. Shared tools/caches/keys, Git history/
tags and other chats' active work are preserved. Compact evidence and an inspected
public-only pip CA bundle are intentionally retained.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 77.16 → 86.49 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta8/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta8/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta8/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta8/android/.gradle`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta8-results/bulk`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta8` |
| linux | 22.61 → 27.39 | `/srv/container-ssd/tmp/codex-preview26-beta8/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta8/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta8/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta8/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta8/bulk`; `/srv/container-ssd/tmp/codex-preview26-beta8/source` |
| signing | 31.72 → 32.67 | `/Users/openclaw/.cache/codex-maia-preview26-beta8/bulk`; `/Users/openclaw/.cache/codex-maia-preview26-beta8/source` |

Task build checkouts were retired after tag/merge checks. The source-only documentation checkout is removed immediately after push; bulk does not wait for documentation CI.
