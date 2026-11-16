# Preview 2.6.0-beta.5 qualification and cleanup

Published 16 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.5), code 2605.
Feature #235 and release #236 are merged. Qualified source `bb375be446fda35475f31e56e4e1d8c70fbfa6e2`
is preserved by the tag; documentation updates do not rebuild the APK.

Concurrent README-only community-link PR237 was reviewed and preserved in the
merge. The release tag retains the exact qualified full source; merged app/build
inputs are identical, while the README differs. The evidence records both trees.

Android system Back from an unfinished game now opens the existing leave
confirmation; cancel retains the game and Continue saves it in Recent games
before returning Home. Back dismisses a completed-game result dialog first,
then returns Home. Settings/list Back and Home exit retain their behavior.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43802181064): 1,406 passed, 4 expected skips; Android passed.
- Canonical and independent Linux unsigned APKs match byte for byte. Production Preview signer continuity, package/version/79M/artwork/licences, payload alignment and byte-identical signature reconstruction passed.
- Full ARM64 API36 real79M native: 16 plus score/continuation tests, all passed on the first exact-source attempt. Expanded oracles: 3,000 positions and 512 variation trees/four round trips; 27 promotion regressions passed.
- 40 focused tests and 14 Back-navigation/channel tests passed, including nine new Back regressions. Stable/unflavored exclusions each passed four tests plus one expected skip. Shared workspace helpers match Stable; 12 helper tests passed in each repository. Static analysis and ordinary localization/terminology checks passed; no translation editorial review was repeated.
- Actual production-signed beta.4 upgrade preserved UID, games/captures/preferences including timing off. Real79M sampling and three game/archive/restart fixtures passed.
- Actual production-signed APK passed Android system-button and real edge-gesture tests: Settings/Recent-list return Home, unfinished confirmation/Back cancel/save, opening saved games, completed result dismissal/Home, normal Home exit and relaunch. Screenshots, source/APK hashes and archive/state evidence are retained in the release bundle. These results do not establish the original reporter's device behavior.
- Actual public downloads matched qualified hashes, established signer, package/version/model/payloads and GitHub digests. Checksums, compact evidence, a public verification receipt and all-host cleanup report accompany the release.

Unsigned SHA-256: `418d777a1916c5984c6c9b482822c1b2d4c52ff8107e2a566aeb382d4c9e0710`.
Signed APK SHA-256: `4a94a57919fce5166d1dc7b34360fd0c9da9ce4df54c1ac61a60cd98bd2b4bac`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev 5M and the withdrawn diagram model are excluded.
APK 455,601,192 bytes; change from beta.4 +0 bytes.

[Fresh upstream review](../dependency-audit-2026-11-16-preview26-beta5.md)
records eleven primary-source groups, 63 clear OSV queries and 19 fresh
hash-verified Pub update decisions. No applicable finding required a pin change;
SDK/runtime/engine/package migrations retain the recorded deferrals. This is an
app navigation fix; no shared build/CI/verification/cleanup helper changed.
Stable companion [#78](https://github.com/Dash1971/maia-chess-android/pull/78)
remains draft and unmerged. Stable/Dev app releases are unchanged.

## Remaining acceptance and cleanup

[Stable #77](https://github.com/Dash1971/maia-chess-android/issues/77) remains open
for reporter/device feedback. Settings and the Recent games list were not
reproduced as defective; their Back paths have regression coverage.
Adaptive-layout acceptance under Preview #29 remains separate. Grand Kingdom
remains experimental with the owner's hardware-drift/calibration explanation
for historical capture symptoms, good operation and a successful 79M Preview
report. DGT remains Dev-only; camera/image recognition remains withdrawn.

Immediately after public-download verification, checked cleanup stopped the
owned emulator/container and removed build intermediates, APK/archive copies,
virtual environment, emulator data and task source/model materializations on
all hosts, before documentation CI. The task's verified idle Gradle daemon and
completed native intermediates were retired earlier after retaining evidence.
Shared tools/caches, keys, Git history/tags and unrelated active checkouts were
preserved. Compact evidence and the inspected public pip CA bundle remain.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 29.10 → 33.20 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta5-results/bulk` |
| linux | 20.63 → 25.02 | `/srv/container-ssd/tmp/codex-preview26-beta5/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta5/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta5/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta5/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta5/bulk` |
| signing | 32.01 → 32.89 | `/Users/openclaw/.cache/codex-maia-preview26-beta5/bulk` |

Build sources were retired after tag/source checks. The source-only documentation checkout is removed immediately after push; no bulk waits for documentation CI.
