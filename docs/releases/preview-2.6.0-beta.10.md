# Preview 2.6.0-beta.10 qualification and cleanup

Published 20 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.10), code 2610. PRs #256/#257/#258 and release #259 are merged; issues #253/#254/#255 are closed. Exact source `89097ac739fb83f08b14cc9c119d27c538870257` is preserved by the release tag. Later documentation does not rebuild the APK.

## Delivered behavior

Damaged temporary saves recover the committed game. Opening an imported PGN or another game keeps the interrupted game in Recent games with its original moves, clock and identity. After a crash, choose the Incomplete entry manually; automatic restore stays blocked until an explicit choice. Full-game computer analysis pauses while the app is backgrounded or another page covers Review, and resumes unfinished work when the same Review page is visible again. Stop, engine-off and line/quality changes discard the pending run.

This resumes in-memory progress while the same Review is open. Completed-report persistence across app restarts remains #61; physical touch/tablet acceptance remains #29.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/44670481582): 1,449 host tests passed with 4 expected skips; Android passed.
- GitHub Linux and the independent Linux build are byte-identical. Established signing continuity, identity/version, model/artwork/licences, alignment and byte-identical signature reconstruction passed.
- Full ARM64 API36 real 79M native: 16 core tests plus score/continuation tests passed. Expanded oracles cover 3,000 positions and 512 variation trees; 27 promotion regressions passed.
- A capacity preflight stopped the next native build before it started after the 16 core tests passed. Retained source/debug-APK/log hashes and checked cleanup retired only completed intermediates. The remaining native tests passed on the unchanged frozen source; disk reserves were preserved.
- Actual production-signed beta.9 upgrade preserved UID, settings, saved games and captures, including timing off. Real 79M play and three saved-game/archive/restart fixtures passed.
- Actual production APK checks cover truncated-UTF8 pending-file recovery, another legal move/save/reopen, shared-PGN import retaining the original identity/history/moves, and manual crash recovery after selecting an older game. Listing leaves the blocked checkpoint untouched and clocks avoid deducting the crash interval.
- Real Stockfish/79M analysis tests cover Android background and coverage by Board Editor, retained position progress in the same process, paused CPU work, complete graph/classification, explicit Stop, engine-off and changed-PGN cancellation. Source/APK-bound JSON/captures are retained.
- Twelve workspace-helper and six security-pin checks passed per repository. The four mandatory shared helpers are identical. [Stable companion #81](https://github.com/Dash1971/maia-chess-android/pull/81) passed its host and Gradle dependency/audit jobs, remains open/unmerged, and does not publish Stable.
- Static analysis, ordinary catalog/terminology checks, channel restrictions and release verification tools passed. The completed editorial translation review was not repeated.
- Public APK/archive/checksums matched qualified bytes and GitHub digests. The public signer/model/payload check and receipt readback passed.

Unsigned SHA-256: `de05497ffeff2d50408309f9fc0074741dbd785079744ea785f40950743c7d66`.
Signed APK SHA-256: `065ffa958a681c829e88150c59e4f10dcacfacb4a952bc1f03fea31dd51fe33d`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M SHA-256: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev 5M and withdrawn diagram model excluded.
APK 455,257,128 bytes; beta.9 delta +0 bytes.

[Fresh upstream review](../dependency-audit-2026-11-20-preview26-beta10.md) records 63 clear exact-version OSV queries, 23 hash-verified package updates/deferrals and the official Gradle 9.9.2 patch/checksum. The ONNX GitHub release/advisory feed returned 404 after repeat requests; accessible official servicing/Maven metadata and exact-version OSV were reviewed. That coverage limit is retained explicitly, without claiming the unavailable feed was clear.

## Cleanup and remaining acceptance

Immediately after actual public-download verification, checked cleanup stopped owned processes and removed task APK/archive/model/venv/AVD/container/build/source copies on every host, before documentation CI. Temporary CI unsigned APK removed; compact verification retained. Shared tools/caches/keys, Git history/tags and unrelated work are preserved. The Stable companion source-only checkout was removed after push, before its CI.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 31.30 → 39.98 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta10/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta10/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta10/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta10/android/.gradle`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta10-results/bulk`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta10` |
| linux | 22.61 → 27.38 | `/srv/container-ssd/tmp/codex-preview26-beta10/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta10/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta10/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta10/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta10/bulk`; `/srv/container-ssd/tmp/codex-preview26-beta10/source` |
| signing | 27.19 → 28.13 | `/Users/openclaw/.cache/codex-maia-preview26-beta10/bulk`; `/Users/openclaw/.cache/codex-maia-preview26-beta10/source` |

Compact evidence and an inspected public-only pip CA bundle are retained. The documentation checkout is removed after push, before CI; merged task branches are retired after ancestry/tag checks. The open Stable companion branch remains for its separate review.

Grand Kingdom remains experimental; the owner attributed historical capture symptoms to hardware drift/calibration and reported good operation. DGT stays Dev-only. Physical touch/tablet and board acceptance remain separate; Stable/Dev app releases are unchanged.
