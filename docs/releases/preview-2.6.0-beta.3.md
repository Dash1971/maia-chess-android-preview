# Preview 2.6.0-beta.3 qualification and cleanup

Published 15 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.3), code 2603.
Feature PRs #224/#226 and release #227 are merged. Qualified source
`4aee6e2a3ff2b38382f3028c9ed62619fd4d3aea` is preserved by the release tag.

Recognition is withdrawn, including its diagram model and capture bridge.
Selected Recent Games save/share one PGN in displayed order, preserving supported
metadata/comments/clocks/variations. Export allows 5 MiB; import and single-game
parser retain 2 MiB. Manual editor/FEN/analysis/continuation remain available.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43664766377): 1,380 passed, 4 expected skips; Android passed.
- Independent Linux unsigned APK matches GitHub byte for byte. Production Preview signer continuity, identity/model/artwork/licence checks and byte-identical signature reconstruction passed.
- Full ARM64 API36 real79M suite: 16 tests plus score/continuation native tests. Expanded oracles: 3,000 positions and 512 variation trees/four round trips.
- 109 focused Preview, 27 promotion, four Stable/unflavored exclusions plus one expected skip each; 12 workspace-helper tests in each repository. Shared helpers remain identical; no applicable tooling port. Translation editorial review was not repeated.
- Actual production-signed beta.2 upgrade preserves UID, games/captures/preferences including timing off. Real79M sampling and three game/archive/restart fixtures passed.
- Fresh offline signed APK: Select all/order/metadata/clocks/variations, save cancellation/retry, 5 MiB UTF-8 overflow and correction, 3.66 MB save/share via a separate test UID, source hashes unchanged and native 2 MiB import rejection. Manual FEN/Analysis/Continue and recognition withdrawal verified in UI and compiled payload.
- Review found P2 sole-receiver self-sharing could auto-import and replace an active game. The fix excludes Maia's own receiving activity from the outgoing chooser; actual single-game regression preserves active/archive bytes with all other receivers disabled. Explicit imports remain available.
- Actual public downloads matched the qualified hashes, established signer and payloads. Compact evidence, checksum and verification receipt are release assets.

Unsigned SHA-256: `971b90998a4821f2216e29c3cdacd95a9a7ef6485ea740877a390f80189c04db`.
Signed APK SHA-256: `92afa224944081e183787b97f43ecc63324f24774292c746355034c29f328139`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. The Dev 5M asset is excluded from the APK.
APK 455,502,888 bytes; change from beta.2 -1,286,444 bytes.

[Fresh upstream review](../dependency-audit-2026-11-15-preview26-beta3.md)
records eleven primary-source groups, 63 clear exact-version OSV queries and
19 fresh hash-verified package-update decisions. No dependency/toolchain changed.
Existing [Stable tooling #73](https://github.com/Dash1971/maia-chess-android/pull/73)
is separate; Stable and Dev releases are unchanged. Stable batch-export issue74
remains a separate feature promotion. Broader recognition #179 remains shelved.

## Limits and cleanup

Grand Kingdom remains experimental. [The owner’s 14 November feedback](https://github.com/Dash1971/maia-chess-android/issues/15#issuecomment-6863134393)
attributes the earlier capture symptoms to hardware drift/calibration and an
uneven surface, confirms firmware 36v5, and reports good overall operation.
The owner subsequently reported a successful 79M Preview game. En passant,
assisted Maia promotion and lifecycle/recovery remain scenario-specific physical
acceptance items; DGT stays Dev-only. Lower-memory and real-phone export
acceptance remain separate from emulator qualification.

Status correction, 15 November: the initial beta.3 release notes and frozen
verification bundle repeated an obsolete unresolved-capture status. The issue
tracker already held the newer hardware feedback; the release documentation
pass failed to reconcile it. Current notes and this report correct that error.
The as-built APK, hashes, qualification results and original verification bundle
remain unchanged; the release includes a separate dated status-correction record.

Immediately after public-download verification, checked cleanup stopped the
owned emulator/idle Gradle daemon/container and removed task intermediates,
APK/archive copies, virtual environment, emulator data and task source/model
materializations on all hosts, before documentation CI. Shared tools/caches,
keys, Git history/tags and unrelated active checkouts were preserved. Compact
evidence and the inspected public pip CA bundle remain.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 26.86 → 35.89 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta3/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta3/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta3/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta3/android/.gradle`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta3-results/bulk` |
| linux | 21.38 → 25.77 | `/srv/container-ssd/tmp/codex-preview26-beta3/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta3/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta3/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta3/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta3/bulk` |
| signing | 32.17 → 33.05 | `/Users/openclaw/.cache/codex-maia-preview26-beta3/bulk` |

Task sources were retired after source/tag checks. The source-only documentation checkout is removed immediately after push. No bulk output waits for documentation CI.
