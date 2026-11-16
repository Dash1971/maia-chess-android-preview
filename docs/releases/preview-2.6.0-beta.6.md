# Preview 2.6.0-beta.6 qualification and cleanup

Published 16 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.6), code 2606.
PR #239 and release #240 are merged. Qualified source `2fefb80867fbb671594e12860b955199ca09e49e` is preserved
by the release tag; later documentation does not rebuild the APK.

Back from a game opened in Recent games now returns to the same list position.
Home always goes Home and clears that browsing context; games started on Home
retain Back-to-Home. The position lives only in a temporary PageStorage bucket:
no preference, dependency, storage format or persistent history is added.
Existing unfinished-game confirmation and result-dialog dismissal remain.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43832983919): 1,416 passed, 4 expected skips; Android passed.
- Canonical and independent Linux unsigned APKs match byte for byte. Production signer continuity, package/version/79M/artwork/licences, payload alignment and byte-identical signature reconstruction passed.
- Full ARM64 API36 real79M native: 16 plus score/continuation tests, all passed on the first exact-source attempt. Expanded oracles: 3,000 positions and 512 variation trees/four round trips; 27 promotion regressions passed.
- 50 focused tests and 24 navigation/channel tests passed, including 19 navigation cases. Host tests cover 80-record lists, normal/large text, predictive Back, finishing incomplete saves, analysis/Home, save failure/retry and repeated Back while saving. Stable/unflavored exclusions each passed four tests plus one expected skip. Twelve workspace-helper tests passed in each repository; shared helpers remain identical. Static analysis and ordinary catalog/terminology contracts passed; no translation editorial review was repeated.
- Actual signed beta.5 upgrade preserved UID, games/captures/preferences including timing off. Real79M sampling and three game/archive/restart fixtures passed.
- Actual production APK with 80 saved games passed system-button/real Android edge-gesture checks in normal/large text: completed and unfinished return at the same row position, confirmation cancellation preserves the game, finishing an incomplete save retains position/identity, analysis Back retains browsing context, Home and analysis Home clear it, and Home-started games still return Home. Archive counts/identities and Home exit/relaunch were checked. Screenshots and source/APK-bound results are retained. Reporter-device behavior still requires confirmation.
- Public APK, compact verification archive and checksums matched qualified bytes and GitHub digests. The established signer, version/model/payloads and public verification receipt passed; the release also carries the cleanup report.

Unsigned SHA-256: `7912806774a8d959efb57e0937d14da07a74ff4537ffe35b0860e6cf20333e08`.
Signed APK SHA-256: `7cc80041c91650d236242926ecb9ab5afbc332627e865b389366960aea0a8ba2`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev 5M and the withdrawn diagram model are excluded.
APK 455,601,192 bytes; change from beta.5 +0 bytes.

[Fresh upstream review](../dependency-audit-2026-11-16-preview26-beta6.md)
records eleven primary-source groups, 63 clear OSV queries and 19 fresh
hash-verified Pub update decisions. No applicable finding required a pin change;
recorded runtime/engine/SDK/package deferrals were reassessed and retained.
Only app navigation changed; no shared build/CI/verification/cleanup helper
requires a port. Stable app promotion remains separate; Stable/Dev releases
are unchanged.

## Remaining acceptance and cleanup

[Stable #77](https://github.com/Dash1971/maia-chess-android/issues/77) stays open
for Prasad's confirmation of the requested browsing behavior. Adaptive-layout
acceptance under Preview #29 remains separate. Grand Kingdom is experimental;
its owner's historical capture symptoms were attributed to hardware drift/
calibration, with good operation and a successful 79M Preview report. DGT stays
Dev-only; camera/image recognition remains withdrawn.

Immediately after verifying public downloads, checked cleanup stopped the owned
emulator/container and removed task intermediates, APK/archive copies, virtual
environment, AVD data and source/model materializations on all hosts, before
documentation CI. The task's idle Gradle daemons and completed native intermediates
were retired earlier after preserving evidence. Shared tools/caches/keys,
Git history/tags and other chats' active work remain. Compact evidence and the
inspected public pip CA bundle are retained.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 27.05 → 31.30 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta6-results/bulk` |
| linux | 23.77 → 28.16 | `/srv/container-ssd/tmp/codex-preview26-beta6/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta6/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta6/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta6/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta6/bulk` |
| signing | 31.98 → 32.86 | `/Users/openclaw/.cache/codex-maia-preview26-beta6/bulk` |

Task build sources were retired after tag/merge checks. The source-only documentation checkout is removed immediately after push; no bulk waits for documentation CI.
