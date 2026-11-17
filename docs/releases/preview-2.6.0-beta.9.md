# Preview 2.6.0-beta.9 qualification and cleanup

Published 17 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.9), code 2609. Feature #249 was already merged; release #250 records qualification. Source `ad82bf5909bfcca1fce0eb90035fb9ad46d7fadf` is preserved by the release tag. Later documentation does not rebuild the APK.

## Delivered behavior

Analysis keeps engine output visible while moves scroll, step or jump to the beginning/end. Engine and move panes scroll independently; landscape tabs share the bottom control strip. Normal-font phone/tablet layouts show both Stockfish and both Maia text lines. Large text uses a separately scrollable header whose offset is unaffected by move interactions.

First/last and repeated holds reveal their destination without rotation, preserving initial-position no-selection and existing variation behavior. Computer-analysis graph endpoint requests apply on return to Moves. Very short windows retain the existing control-access fallback; they cannot guarantee all engine rows simultaneously.

## Qualification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/44079286467): 1,445 tests passed, 4 expected skips; Android passed.
- Canonical GitHub Linux and independent Linux unsigned APKs are byte-identical. Production signer continuity, identity/version, real79M/artwork/licences/alignment and signature reconstruction passed.
- Full ARM64 API36 real79M native suite: 16 plus two feature tests passed. Expanded oracles: 3,000 positions and 512 variation trees; 27 promotion regressions passed.
- 126 focused real-font checks, 46 score/channel checks, 24 default-font fixed-pane checks passed. Stable/unflavored exclusions each passed four tests plus one expected skip. Static analysis, catalogs and terminology contracts passed; no repeated translation editorial review.
- Shared helpers match current Stable; 12 helper tests passed per repository. No tooling port applies to this app-only UI change.
- Actual production-signed beta.8 upgrade preserved UID, settings, saved games and captures, including timing off. Real79M play and three saved-game/archive/restart fixtures passed.
- Actual production APK phone/tablet portrait/landscape and large-text checks verified the engine region stays visible during move scrolling, stepping and first/last/repeated holds. Normal-font engine rows retain their coordinates; at 200% the populated opening label can be taller, so same-position and manual-offset comparisons distinguish content layout from scrolling. Normal-font layouts show readable Stockfish and Maia lines; the three-button phone capture trims bottom row padding while retaining all text. The original padding-only harness assertion and correction are retained; manually scrolling a constrained large-text header retains its offset across move interactions. Real graph completion, graph endpoint requests, rotation and 480×260 control access passed. Source/APK-bound results and captures are retained.
- Public APK/archive/checksum downloads matched qualified bytes and GitHub digests. Public signer, model/payload verification and receipt readback passed.

Unsigned SHA-256: `b862da7d3e42c17cd3edbc18e971c84ea892fba91117bb914cebf04cb4d099b5`.
Signed APK SHA-256: `6d984365bb7a48cce18916497e13a1c4fa53d428a493dfa918d649f03ac94b43`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M SHA-256: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Dev5M and withdrawn diagram model excluded.
APK 455,257,128 bytes; beta.8 delta -278,528 bytes.

[Fresh upstream review](../dependency-audit-2026-11-17-preview26-beta9.md) records eleven primary-source groups, 63 clear OSV queries and 19 hash-verified update decisions. Stable ADB37.0.1 remains preferable to Canary37.0.3. No applicable finding required a pin change.

## Remaining acceptance and cleanup

Physical touch/tablet and OS split-screen acceptance remain open under #29. Emulator evidence does not establish reporter-device satisfaction. Grand Kingdom remains experimental; the owner's historical capture symptoms were attributed to hardware drift/calibration with good operation reported. DGT remains Dev-only. Stable/Dev releases are unchanged.

Immediately after public-download verification, checked cleanup stopped owned processes and removed task APK/archive/venv/AVD/container/build/source/model copies on all hosts, before documentation CI. The verified idle task Gradle daemon was stopped. Temporary unsigned CI APK removed; compact verification retained. Shared tools/caches/keys, Git tags/history and unrelated work remain intact.

| Host | Free before/after cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 73.91 → 82.97 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta9/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta9/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta9/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta9/android/.gradle`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta9-results/bulk`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta9` |
| linux | 22.62 → 27.39 | `/srv/container-ssd/tmp/codex-preview26-beta9/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta9/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta9/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta9/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta9/bulk`; `/srv/container-ssd/tmp/codex-preview26-beta9/source` |
| signing | 31.69 → 32.64 | `/Users/openclaw/.cache/codex-maia-preview26-beta9/bulk`; `/Users/openclaw/.cache/codex-maia-preview26-beta9/source` |

Compact hashes/logs/captures and inspected public-only pip CA retained. Source-only documentation checkout removed after push, before its CI; merged task branches retired after ancestry checks.
