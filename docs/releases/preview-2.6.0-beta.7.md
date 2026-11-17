# Preview 2.6.0-beta.7 qualification and cleanup

Published 17 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.7), code 2607.
PRs #242/#243 and release #244 are merged. Qualified source `74eebaeaa82b2fc9bac4bbb3f0d270ea5facc9a2` is
preserved by the release tag; subsequent documentation does not rebuild the APK.

Landscape Analysis now scrolls opening information, engine output, tabs and
moves/graph in one pane beside a stationary board. Navigation stays fixed where
space permits, with a scrolling fallback for short windows. Tablet/resized pane
widths, initial engine visibility, selected-move reveal and separate tab offsets
are preserved. Recent games uses yyyy/MM/dd dates, measured columns, centered
player/result text and a full muted Incomplete label, with a narrow/large-text
fallback. Per-row trash is removed; selection provides deletion and Back first
cancels selection. Previous saved-game return position and PGN export remain.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43973988387): 1,436 passed, 4 expected skips; Android passed.
- Canonical and independent Linux unsigned APKs match byte for byte. Established production signer, package/version, 79M/artwork/licences, alignment and byte-identical signature reconstruction passed.
- Full ARM64 API36 real79M native: 16 plus score/continuation tests, all passed. Expanded oracles: 3,000 positions and 512 variation trees/four round trips; 27 promotion regressions passed.
- 337 focused tests with real Roboto and 31 Analysis/adaptive/channel tests passed. Stable/unflavored exclusions each passed four tests plus one expected skip. Twelve workspace-helper tests passed in each repository; shared helpers are identical. Static analysis and catalog/terminology contracts passed; translation editorial review was not repeated.
- Actual production-signed beta.6 upgrade preserved UID, games/captures/preferences including timing off. Real79M sampling and three game/archive/restart fixtures passed.
- Actual signed APK Analysis checks cover phone/tablet/4:3/resized windows, normal/large text, continuous engine-to-moves scrolling, manual scroll retention, stationary board, real79M primary/secondary rows, completed computer-analysis graph, navigation/tab position, rotation and 480×260 short-screen control access including Android system bars (host tests separately cover 480×200). The first graph return adjusted the tab by 10 pixels; three subsequent round trips restored identical bounds without drift or position loss. Resized windows do not claim actual OS split-screen or physical tablet acceptance.
- Actual signed APK Recent games checks use 80 fixtures with Android buttons and real edge gestures, normal/large text: date/trash/selection changes, Back cancels selection, completed/unfinished return position, confirmation cancellation, finishing an incomplete save, analysis/Home flows, export picker cancellation and selected deletion/cancellation. Archive identity/count and unaffected file hashes are checked.
- Public APK, verification archive and checksums match qualified bytes and GitHub digests. The public signer/model/payload verification and receipt passed; a separate cleanup report is attached.

Unsigned SHA-256: `628b45b2c1379705be52bc6dce6eb12e4f083b49d926e911bc2d078671c1f6a9`.
Signed APK SHA-256: `8b040438edf2dc96b6ba6e4e67ca20e05a588665049df346c25ea55efa713d6e`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev 5M and withdrawn diagram model are excluded.
APK 455,257,128 bytes; change from beta.6 -344,064 bytes.

[Fresh upstream review](../dependency-audit-2026-11-17-preview26-beta7.md)
records eleven primary-source groups, 63 clear OSV queries and 19 fresh
hash-verified Pub update decisions. Applicable update deferrals were reassessed;
no pin change was required. Only app UI changed; no shared tooling port applies.
Stable and Dev releases remain unchanged; Stable promotion is separate.

## Remaining acceptance and cleanup

Preview #29 remains open for physical touch/tablet and device-specific acceptance.
Grand Kingdom remains experimental; historical capture symptoms were attributed
by the owner to hardware drift/calibration, with good operation reported. DGT
stays Dev-only; camera/image recognition remains withdrawn.

Immediately after public-download verification, checked cleanup stopped the owned
emulator/container and removed task intermediates, APK/archive copies, virtual
environment, AVD and source/model copies on every host before documentation CI.
Task idle Gradle daemons and completed native intermediates were retired earlier.
The task’s temporary GitHub unsigned APK artifact was removed after public verification; compact CI verification and logs remain. Shared tools/caches/keys, Git history/tags and other active work remain. Compact
evidence and an inspected public pip CA bundle are retained.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 22.85 → 28.65 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta7-results/bulk`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta7` |
| linux | 22.62 → 27.39 | `/srv/container-ssd/tmp/codex-preview26-beta7/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta7/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta7/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta7/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta7/bulk`; `/srv/container-ssd/tmp/codex-preview26-beta7/source` |
| signing | 31.87 → 32.81 | `/Users/openclaw/.cache/codex-maia-preview26-beta7/bulk`; `/Users/openclaw/.cache/codex-maia-preview26-beta7/source` |

Build checkouts were retired after tag/merge checks. The source-only documentation checkout is removed immediately after push; bulk does not wait for documentation CI.
