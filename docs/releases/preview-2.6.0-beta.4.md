# Preview 2.6.0-beta.4 qualification and cleanup

Published 15 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.4), code 2604.
Feature #231 and release #232 are merged. Qualified source `36c63023b4a1166e5ca6c6772acd445c59c46d1e`
is preserved by the release tag; later documentation does not rebuild the APK.

Landscape gameplay/Analysis give the board more height with adjacent controls.
Wide Home and Settings use columns. Recent games uses aligned Date/Game/Result
rows, preserving direct opening, selection, deletion and PGN export. Engine
algorithms, storage formats, limits and channel restrictions are unchanged.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43702696569): 1,397 passed, 4 expected skips; Android passed.
- Independent Linux unsigned APK matches GitHub byte for byte. Production Preview signer continuity, identity/79M/artwork/licence checks and byte-identical signature reconstruction passed.
- Full ARM64 API36 real79M native: 16 tests plus score/continuation tests. Expanded oracles: 3,000 positions and 512 variation trees/four round trips; 27 promotion regressions.
- 291 focused layout/analysis/storage/export tests, 16 Preview layout/channel tests, four Stable/unflavored exclusions plus one expected skip each, and 12 workspace tests in each repository passed. Static analysis and ordinary 468-message/catalog/terminology checks passed. No translation editorial review was repeated.
- Initial native run hit a System UI ANR dialog that held focus. Android correctly denied clipboard access, causing three clipboard assertions and a cascading archive-count failure. Diagnostics were retained; normal focus was restored without disabling OS permissions, SELinux or clipboard policy. Checked cleanup reclaimed abandoned intermediates for the required disk budget; the unchanged full source then passed.
- Review found a 148px board at 480×240 with Android bars: the sidebar threshold omitted 16dp board padding. The corrected threshold has a failing-before/passing-after regression and was requalified from a fresh frozen source.
- The current continuation fixture first read a null saved session immediately after starting. Its original diagnostic is retained; an unchanged retry passed the complete history/FEN/handoff/real79M assertions.
- Actual production-signed beta.3 upgrade preserves UID, games/captures/preferences including timing off. Real79M sampling and three game/archive/restart fixtures passed.
- Actual production-signed APK verified adaptive boards and controls on phone/tablet/constrained/large-text profiles, rotation and input/premoves/promotion, Analysis graph/navigation, Settings persistence, compact-history opening/selection/export and restore. Compact screenshots/geometry/data checks are in the release bundle.
- Actual public downloads matched qualified hashes, established signer, identity/model/payloads and GitHub digests. The release includes checksums, compact evidence and a public verification receipt.

Unsigned SHA-256: `93af20d0a9b8c9ce0f855df283c283a69ced4a1eda182ae977e73ee873ba6037`.
Signed APK SHA-256: `6127fbb36c7ca1715dcb889ea47d60b4555b6204181a0b58ee8c1b0bb027d8a7`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev 5M and the withdrawn diagram model are excluded.
APK 455,601,192 bytes; change from beta.3 +98,304 bytes.

[Fresh upstream review](../dependency-audit-2026-11-15-preview26-beta4.md)
records eleven primary-source groups, 63 clear OSV queries and 19 fresh
hash-verified Pub update decisions. The new Stockfish development NNUE/search
change is deferred; no dependency/toolchain changed. Shared helpers remain
identical to current Stable and no tooling companion port applies. Stable/Dev
app releases are unchanged; existing Stable tooling #73 remains separate.

## Remaining acceptance and cleanup

[#29](https://github.com/Dash1971/maia-chess-android-preview/issues/29) stays open
for gesture navigation, actual Android split-screen behavior, comfortable
physical finger input and tablet-owner feedback; emulator
qualification does not establish those outcomes. Grand Kingdom remains
experimental with the owner's hardware-drift/calibration explanation for earlier
capture symptoms (firmware 36v5), good overall operation and a successful 79M
Preview report. Untested en-passant/promotion/recovery scenarios remain separate;
DGT stays Dev-only. Camera/image recognition remains withdrawn.

Immediately after public-download verification, checked cleanup stopped the
owned emulator/idle Gradle daemon/container and removed task intermediates,
APK/archive copies, virtual environment, emulator data and task source/model
materializations on all hosts, before documentation CI. Shared tools/caches,
keys, Git history/tags and unrelated active checkouts were preserved. Compact
evidence and the inspected public pip CA bundle remain.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 28.86 → 34.73 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta4/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta4/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta4/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta4-results/bulk` |
| linux | 21.37 → 25.77 | `/srv/container-ssd/tmp/codex-preview26-beta4/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta4/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta4/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta4/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta4/bulk` |
| signing | 32.11 → 32.99 | `/Users/openclaw/.cache/codex-maia-preview26-beta4/bulk` |

Task sources were retired after source/tag checks. The source-only documentation checkout is removed immediately after push. No bulk output waits for documentation CI.
